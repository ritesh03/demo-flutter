/// This class is a modified version of [GetSnackBar] from below package:
///
/// Package: [https://pub.dev/packages/get]
/// Repository: [https://github.com/jonataslaw/getx]
/// version: 4.6.1
/// commit: fa1888be
///
/// These classes, still, rely on following components from Source Package:
/// * [Get] & [GetNavigation] to get the "overlayContext".
/// * [GetMaterialApp] to create above said "overlayContext".
/// * [GetQueue] to register notification bar controllers.
///
/// In future, with enough time, you might want to detach this
/// functionality from [Get]. To do this, find a way to create
/// "overlayContext" without them.
///
/// When the package has released newer versions, please check
/// for any breaking changes.
///
/// Added: 15 March, 2022
/// Modified: Never
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' show Get, GetNavigation, GetQueue;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

typedef NotificationBarStatusCallback = void Function(
    NotificationBarStatus? status);

class NotificationBar extends StatefulWidget {
  /// The notification information shown to the user
  final NotificationBarInfo info;

  /// Background color for [NotificationBar]
  final Color? backgroundColor;

  /// [boxShadows] The shadows generated by [NotificationBar]. Leave it null
  /// if you don't want a shadow.
  /// You can use more than one if you feel the need.
  /// Check (this example)[https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/shadows.dart]
  final List<BoxShadow>? boxShadows;

  /// How long until [NotificationBar] will hide itself (be dismissed).
  /// To make it indefinite, leave it null.
  final Duration? duration;

  /// Determines if the user can swipe or click the overlay
  /// (if [overlayBlur] > 0) to dismiss.
  /// It is recommended that you set [duration] != null if this is false.
  /// If the user swipes to dismiss or clicks the overlay, no value
  /// will be returned.
  final bool isDismissible;

  /// The direction in which the [NotificationBar] can be dismissed.
  ///
  /// Default is [DismissDirection.down] when
  /// [position] == [NotificationBarPosition.bottom] and [DismissDirection.up]
  /// when [position] == [NotificationBarPosition.top]
  final DismissDirection? dismissDirection;

  /// Used to limit [NotificationBar] width (usually on large screens)
  final double? maxWidth;

  /// Adds a custom margin to [NotificationBar]
  final EdgeInsets margin;

  /// Adds a custom padding to [NotificationBar]
  /// The default follows material design guide line
  final EdgeInsets padding;

  /// Adds a radius to [NotificationBar]. Best combined with [margin].
  final BorderRadius? borderRadius;

  /// Adds a border to [NotificationBar]
  final Border? border;

  /// [NotificationBar] can be based on [NotificationBarPosition.top] or
  /// on [NotificationBarPosition.bottom] of your screen.
  /// [NotificationBarPosition.bottom] is the default.
  final NotificationBarPosition position;

  /// [NotificationBar] can be floating or be grounded to the edge of the screen.
  /// If grounded, I do not recommend using [margin] or [borderRadius].
  /// [NotificationBarStyle.floating] is the default.
  /// If grounded, I do not recommend using a [backgroundColor] with
  /// transparency or [barBlur]
  final NotificationBarStyle style;

  /// The [Curve] animation used when show() is called.
  /// [Curves.easeOut] is default
  final Curve forwardAnimationCurve;

  /// The [Curve] animation used when dismiss() is called.
  /// [Curves.fastOutSlowIn] is default
  final Curve reverseAnimationCurve;

  /// Use it to speed up or slow down the animation duration
  final Duration animationDuration;

  /// Default is 0.0. If different than 0.0, blurs only [NotificationBar]'s background.
  /// To take effect, make sure your [backgroundColor] has some opacity.
  /// The greater the value, the greater the blur.
  final double barBlur;

  /// Default is 0.0. If different than 0.0, creates a blurred
  /// overlay that prevents the user from interacting with the screen.
  /// The greater the value, the greater the blur.
  final double overlayBlur;

  /// Default is [Colors.transparent]. Only takes effect if [overlayBlur] > 0.0.
  /// Make sure you use a color with transparency here e.g.
  /// Colors.grey[600].withOpacity(0.2).
  final Color? overlayColor;

  /// A callback for you to listen to the different [NotificationBar] status
  final NotificationBarStatusCallback? statusCallback;

  const NotificationBar({
    Key? key,
    required this.info,
    this.backgroundColor = const Color(0xFFFF0000),
    this.boxShadows,
    this.duration,
    this.isDismissible = true,
    this.dismissDirection,
    this.maxWidth,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    this.borderRadius,
    this.border,
    this.position = NotificationBarPosition.bottom,
    this.style = NotificationBarStyle.floating,
    this.forwardAnimationCurve = Curves.easeOutCirc,
    this.reverseAnimationCurve = Curves.easeOutCirc,
    this.animationDuration = const Duration(seconds: 1),
    this.barBlur = 0.0,
    this.overlayBlur = 0.0,
    this.overlayColor = Colors.transparent,
    this.statusCallback,
  }) : super(key: key);

  @override
  State createState() => NotificationBarState();
}

class NotificationBarState extends State<NotificationBar>
    with TickerProviderStateMixin {
  final Widget _emptyWidget = const SizedBox(width: 0.0, height: 0.0);

  final Completer<Size> _boxHeightCompleter = Completer<Size>();

  final _backgroundBoxKey = GlobalKey();

  double get buttonPadding {
    if (widget.padding.right - 12 < 0) {
      return 4;
    } else {
      return widget.padding.right - 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        heightFactor: 1.0,
        child: Material(
            color: widget.style == NotificationBarStyle.floating
                ? Colors.transparent
                : widget.backgroundColor,
            child: SafeArea(
                minimum: widget.position == NotificationBarPosition.bottom
                    ? EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom)
                    : EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                bottom: widget.position == NotificationBarPosition.bottom,
                top: widget.position == NotificationBarPosition.top,
                left: false,
                right: false,
                child: Stack(children: [
                  /// BLUR + BOX-HEIGHT
                  _buildBlurBackground(),

                  /// UI
                  _buildContent()
                ]))));
  }

  @override
  void initState() {
    super.initState();

    _configureLeftBarFuture();
  }

  Widget _buildBlurBackground() {
    return FutureBuilder<Size>(
        future: _boxHeightCompleter.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (widget.barBlur == 0) {
              return _emptyWidget;
            }
            return ClipRRect(
                borderRadius: widget.borderRadius,
                child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: widget.barBlur, sigmaY: widget.barBlur),
                    child: Container(
                        height: snapshot.data!.height,
                        width: snapshot.data!.width,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: widget.borderRadius,
                        ))));
          } else {
            return _emptyWidget;
          }
        });
  }

  Widget _buildContent() {
    return _NotificationBarContent(key: _backgroundBoxKey, info: widget.info);

    // final iconPadding = widget.padding.left > 16.0 ? widget.padding.left : 0.0;
    // final left = _rowStyle == RowStyle.icon || _rowStyle == RowStyle.all
    //     ? 4.0
    //     : widget.padding.left;
    // final right = _rowStyle == RowStyle.action || _rowStyle == RowStyle.all
    //     ? 8.0
    //     : widget.padding.right;
    // return Container(
    //   key: _backgroundBoxKey,
    //   constraints: widget.maxWidth != null
    //       ? BoxConstraints(maxWidth: widget.maxWidth!)
    //       : null,
    //   decoration: BoxDecoration(
    //     color: widget.backgroundColor,
    //     gradient: widget.backgroundGradient,
    //     boxShadow: widget.boxShadows,
    //     borderRadius: BorderRadius.circular(widget.borderRadius),
    //     border: widget.borderColor != null
    //         ? Border.all(color: widget.borderColor!, width: widget.borderWidth!)
    //         : null,
    //   ),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       widget.showProgressIndicator
    //           ? LinearProgressIndicator(
    //         value: widget.progressIndicatorController != null
    //             ? _progressAnimation.value
    //             : null,
    //         backgroundColor: widget.progressIndicatorBackgroundColor,
    //         valueColor: widget.progressIndicatorValueColor,
    //       )
    //           : _emptyWidget,
    //       Row(
    //         mainAxisSize: MainAxisSize.max,
    //         children: [
    //           _buildLeftBarIndicator(),
    //           if (_rowStyle == RowStyle.icon || _rowStyle == RowStyle.all)
    //             ConstrainedBox(
    //               constraints:
    //               BoxConstraints.tightFor(width: 42.0 + iconPadding),
    //               child: _getIcon(),
    //             ),
    //           Expanded(
    //             flex: 1,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.stretch,
    //               mainAxisSize: MainAxisSize.min,
    //               children: <Widget>[
    //                 if (_isTitlePresent)
    //                   Padding(
    //                     padding: EdgeInsets.only(
    //                       top: widget.padding.top,
    //                       left: left,
    //                       right: right,
    //                     ),
    //                     child: widget.titleText ??
    //                         Text(
    //                           widget.title ?? "",
    //                           style: TextStyle(
    //                             fontSize: 16.0,
    //                             color: Colors.white,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                         ),
    //                   )
    //                 else
    //                   _emptyWidget,
    //                 Padding(
    //                   padding: EdgeInsets.only(
    //                     top: _messageTopMargin,
    //                     left: left,
    //                     right: right,
    //                     bottom: widget.padding.bottom,
    //                   ),
    //                   child: widget.messageText ??
    //                       Text(
    //                         widget.message ?? "",
    //                         style:
    //                         TextStyle(fontSize: 14.0, color: Colors.white),
    //                       ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           if (_rowStyle == RowStyle.action || _rowStyle == RowStyle.all)
    //             Padding(
    //               padding: EdgeInsets.only(right: buttonPadding),
    //               child: widget.mainButton,
    //             ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }

  void _configureLeftBarFuture() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        final keyContext = _backgroundBoxKey.currentContext;
        if (keyContext != null) {
          final box = keyContext.findRenderObject() as RenderBox;
          _boxHeightCompleter.complete(box.size);
        }
      },
    );
  }
}

class _NotificationBarContent extends StatelessWidget {
  const _NotificationBarContent({
    Key? key,
    required this.info,
  }) : super(key: key);

  final NotificationBarInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).white(),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        padding: EdgeInsets.all(ComponentInset.small.r),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          _NotificationBarActionTypeIndicator(type: info.type),
          SizedBox(width: ComponentInset.small.w),
          Expanded(child: _buildContent(context)),
          SizedBox(width: ComponentInset.small.w),
          _buildCloseButton(context),
        ]));
  }

  Widget _buildContent(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.hasTitle) _buildTitle(context),
          _buildMessage(context),
          if (info.hasAction) _buildActionButton(context),
        ]);
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
        constraints: BoxConstraints(minHeight: ComponentSize.small.r),
        alignment: Alignment.centerLeft,
        child: Text(
          info.title!,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyles.boldBody
              .copyWith(color: DynamicTheme.get(context).background()),
        ));
  }

  Widget _buildMessage(BuildContext context) {
    return Container(
        constraints: BoxConstraints(minHeight: ComponentSize.small.r),
        alignment: Alignment.centerLeft,
        child: Text(
          info.message,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          maxLines: 6,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).background()),
        ));
  }

  Widget _buildActionButton(BuildContext context) {
    return Button(
        text: info.actionText!,
        type: ButtonType.text,
        onPressed: () {
          info.actionCallback!(context);
          _hide(context);
        });
  }

  Widget _buildCloseButton(BuildContext context) {
    return AppIconButton(
      width: ComponentSize.small.r,
      height: ComponentSize.small.r,
      assetPath: Assets.iconCrossBold,
      assetColor: DynamicTheme.get(context).neutral10(),
      padding: EdgeInsets.all(ComponentInset.smaller.r),
      onPressed: () => _hide(context),
    );
  }

  /*
   * ACTIONS
   */

  void _hide(BuildContext context) {
    NotificationBarController.closeCurrentNotificationBar();
  }
}

/// Indicates Status of [NotificationBar].
/// [NotificationBarStatus.open] notification-bar is fully open,
/// [NotificationBarStatus.closed] notification-bar has closed,
/// [NotificationBarStatus.opening] Starts with the opening animation and ends
/// with the full notification-bar display,
/// [NotificationBarStatus.closing] Starts with the closing animation
/// and ends with the full notification-bar dispose
enum NotificationBarStatus { open, closed, opening, closing }

/// Indicates if [NotificationBar] is going to start at the [top] or at the [bottom]
enum NotificationBarPosition { top, bottom }

/// Indicates if [NotificationBar] will be attached to the edge of the screen or not
enum NotificationBarStyle { floating, grounded }

/// Indicates if [NotificationBar] is a [success] or [error] event
enum NotificationBarActionType { success, error }

/// Shows [NotificationBarActionType.success] or [NotificationBarActionType.error]
/// UI for [NotificationBar]
class _NotificationBarActionTypeIndicator extends StatelessWidget {
  const _NotificationBarActionTypeIndicator({
    Key? key,
    required this.type,
  }) : super(key: key);

  final NotificationBarActionType? type;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: obtainBackgroundColor(context),
            borderRadius: BorderRadius.circular(6.r)),
        child: SvgPicture.asset(
          obtainIconAssetPath(),
          width: ComponentSize.smaller.r,
          height: ComponentSize.smaller.r,
          color: DynamicTheme.get(context).white(),
        ));
  }

  Color obtainBackgroundColor(BuildContext context) {
    switch (type) {
      case null:
        return DynamicTheme.get(context).neutral20();
      case NotificationBarActionType.success:
        return DynamicTheme.get(context).success120();
      case NotificationBarActionType.error:
        return DynamicTheme.get(context).error100();
    }
  }

  String obtainIconAssetPath() {
    switch (type) {
      case null:
        return Assets.iconCheckBold;
      case NotificationBarActionType.success:
        return Assets.iconCheckBold;
      case NotificationBarActionType.error:
        return Assets.iconCrossBold;
    }
  }
}

/// Contains information about the notification being shown
class NotificationBarInfo {
  final String? title;
  final String message;
  final NotificationBarActionType? type;
  final String? actionText;
  final Function(BuildContext)? actionCallback;

  const NotificationBarInfo({
    this.title,
    required this.message,
    this.actionText,
    this.actionCallback,
  }) : type = null;

  const NotificationBarInfo.success({
    this.title,
    required this.message,
    this.actionText,
    this.actionCallback,
  }) : type = NotificationBarActionType.success;

  const NotificationBarInfo.error({
    this.title,
    required this.message,
    this.actionText,
    this.actionCallback,
  }) : type = NotificationBarActionType.error;

  bool get hasTitle => (title != null && title!.isNotEmpty);

  bool get hasAction =>
      (actionText != null && actionText!.isNotEmpty && actionCallback != null);
}

/// A controller that shows and hides the [NotificationBar] along
/// with maintaining its lifecycle
class NotificationBarController {
  //=

  static NotificationBarController showNotificationBar(
      NotificationBar notificationBar) {
    //=
    final controller = NotificationBarController(notificationBar);
    controller.show();
    return controller;
  }

  static final _notificationBarQueue = _NotificationBarQueue();

  static bool get isNotificationBarBeingShown =>
      _notificationBarQueue._isJobInProgress;
  final key = GlobalKey<NotificationBarState>();

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final NotificationBar notificationBar;
  final _transitionCompleter = Completer();

  late NotificationBarStatusCallback? _statusCallback;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  bool _wasDismissedBySwipe = false;

  bool _onTappedDismiss = false;

  Timer? _timer;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  late final Animation<Alignment> _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the [animation] property.
  late final AnimationController _controller;

  NotificationBarStatus? _currentStatus;

  final _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  NotificationBarController(this.notificationBar);

  Future<void> get future => _transitionCompleter.future;

  /// Close the [NotificationBar] with animation
  Future<void> close({bool withAnimations = true}) async {
    if (!withAnimations) {
      _removeOverlay();
      return;
    }
    _removeEntry();
    await future;
  }

  /// Adds [NotificationBar] to a view queue.
  /// Only one [NotificationBar] will be displayed at a time,
  /// and this method returns a future to when the [NotificationBar] disappears.
  Future<void> show() {
    return _notificationBarQueue._addJob(this);
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  // ignore: avoid_returning_this
  void _configureAlignment(NotificationBarPosition position) {
    switch (notificationBar.position) {
      case NotificationBarPosition.top:
        {
          _initialAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case NotificationBarPosition.bottom:
        {
          _initialAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  void _configureOverlay() {
    _overlayState = Overlay.of(Get.overlayContext!);
    _overlayEntries.clear();
    _overlayEntries.addAll(_createOverlayEntries(_getBodyWidget()));
    _overlayState!.insertAll(_overlayEntries);
    _configureNotificationBarDisplay();
  }

  void _configureNotificationBarDisplay() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot configure a NotificationBar after disposing it.');
    _controller = _createAnimationController();
    _configureAlignment(notificationBar.position);
    _statusCallback = notificationBar.statusCallback;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation.addStatusListener(_handleStatusChanged);
    _configureTimer();
    _controller.forward();
  }

  void _configureTimer() {
    if (notificationBar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(notificationBar.duration!, _removeEntry);
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animation from a disposed NotificationBar');
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: notificationBar.forwardAnimationCurve,
        reverseCurve: notificationBar.reverseAnimationCurve,
      ),
    );
  }

  /// Called to create the animation controller that will drive the transitions
  /// to this route from the previous one, and back to the previous route
  /// from this one.
  AnimationController _createAnimationController() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animationController from a disposed NotificationBar');
    assert(notificationBar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: notificationBar.animationDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: notificationBar.overlayBlur)
        .animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.35,
              curve: Curves.easeInOutCirc,
            )));
  }

  Animation<Color?> _createColorOverlayColor() {
    return ColorTween(
            begin: const Color(0x00000000), end: notificationBar.overlayColor)
        .animate(CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.35,
              curve: Curves.easeInOutCirc,
            )));
  }

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) {
    return <OverlayEntry>[
      if (notificationBar.overlayBlur > 0.0) ...[
        OverlayEntry(
          builder: (context) => GestureDetector(
              onTap: () {
                if (notificationBar.isDismissible && !_onTappedDismiss) {
                  _onTappedDismiss = true;
                  close();
                }
              },
              child: AnimatedBuilder(
                  animation: _filterBlurAnimation,
                  builder: (context, child) {
                    return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: max(0.001, _filterBlurAnimation.value),
                          sigmaY: max(0.001, _filterBlurAnimation.value),
                        ),
                        child: Container(
                          constraints: const BoxConstraints.expand(),
                          color: _filterColorAnimation.value,
                        ));
                  })),
          maintainState: false,
          opaque: false,
        )
      ],
      OverlayEntry(
        builder: (context) => Semantics(
          focused: false,
          container: true,
          explicitChildNodes: true,
          child: AlignTransition(
            alignment: _animation,
            child: notificationBar.isDismissible
                ? _getDismissibleNotificationBar(child)
                : _getNotificationBarContainer(child),
          ),
        ),
        maintainState: false,
        opaque: false,
      ),
    ];
  }

  Widget _getBodyWidget() {
    return Builder(builder: (_) {
      return notificationBar;
    });
  }

  DismissDirection _getDefaultDismissDirection() {
    if (notificationBar.position == NotificationBarPosition.top) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  Widget _getDismissibleNotificationBar(Widget child) {
    return Dismissible(
      direction:
          notificationBar.dismissDirection ?? _getDefaultDismissDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (_currentStatus == NotificationBarStatus.opening ||
            _currentStatus == NotificationBarStatus.closing) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      key: const Key('dismissible'),
      onDismissed: (_) {
        _wasDismissedBySwipe = true;
        _removeEntry();
      },
      child: _getNotificationBarContainer(child),
    );
  }

  Widget _getNotificationBarContainer(Widget child) {
    return Container(
      margin: notificationBar.margin,
      child: child,
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = NotificationBarStatus.open;
        _statusCallback?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;

        break;
      case AnimationStatus.forward:
        _currentStatus = NotificationBarStatus.opening;
        _statusCallback?.call(_currentStatus);
        break;
      case AnimationStatus.reverse:
        _currentStatus = NotificationBarStatus.closing;
        _statusCallback?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!_overlayEntries.first.opaque);
        _currentStatus = NotificationBarStatus.closed;
        _statusCallback?.call(_currentStatus);
        _removeOverlay();
        break;
    }
  }

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove entry from a disposed NotificationBar',
    );

    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), _controller.reset);
      _wasDismissedBySwipe = false;
    } else {
      _controller.reverse();
    }
  }

  void _removeOverlay() {
    for (var element in _overlayEntries) {
      element.remove();
    }

    assert(!_transitionCompleter.isCompleted,
        'Cannot remove overlay from a disposed NotificationBar');
    _controller.dispose();
    _overlayEntries.clear();
    _transitionCompleter.complete();
  }

  Future<void> _show() {
    _configureOverlay();
    return future;
  }

  static void cancelAll() {
    _notificationBarQueue._cancelAllJobs();
  }

  static Future<void> closeCurrentNotificationBar() async {
    await _notificationBarQueue._closeCurrentJob();
  }
}

/// A queue of controllers/jobs to keep track of active/pending
/// controllers
class _NotificationBarQueue {
  final _queue = GetQueue();
  final _controllers = <NotificationBarController>[];

  NotificationBarController? get _currentController {
    if (_controllers.isEmpty) return null;
    return _controllers.first;
  }

  bool get _isJobInProgress => _controllers.isNotEmpty;

  Future<void> _addJob(NotificationBarController job) async {
    _controllers.add(job);
    final data = await _queue.add(job._show);
    _controllers.remove(job);
    return data;
  }

  Future<void> _cancelAllJobs() async {
    await _currentController?.close();
    _queue.cancelAllJobs();
    _controllers.clear();
  }

  Future<void> _closeCurrentJob() async {
    if (_currentController == null) return;
    await _currentController!.close();
  }
}

/// Convenience method to show [NotificationBar]
NotificationBarController showDefaultNotificationBar(
  NotificationBarInfo notificationBarInfo, {
  bool closePreviousNotificationBar = true,
  bool autoClose = true,
}) {
  //=
  if (closePreviousNotificationBar) {
    closeCurrentNotificationBar();
  }

  final controller = NotificationBarController(NotificationBar(
    info: notificationBarInfo,
    animationDuration: const Duration(milliseconds: 500),
    duration: autoClose ? const Duration(seconds: 4) : null,
    position: NotificationBarPosition.top,
    margin: EdgeInsets.all(ComponentInset.normal.r),
  ));
  controller.show();
  return controller;
}

/// Convenience method to hide [NotificationBar]
void closeCurrentNotificationBar() {
  NotificationBarController.closeCurrentNotificationBar();
}
