import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class PageTitleBarWrapper extends StatefulWidget {
  const PageTitleBarWrapper({
    Key? key,
    required this.barHeight,
    required this.title,
    this.centerTitle = true,
    required this.actions,
    required this.child,
  }) : super(key: key);

  final double barHeight;
  final Widget title;
  final bool centerTitle;
  final List<Widget> actions;
  final Widget child;

  @override
  State<PageTitleBarWrapper> createState() => _PageTitleBarWrapperState();
}

class _PageTitleBarWrapperState extends State<PageTitleBarWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  double get _animatedValue => _animationController.value;

  double get _barHeightOffset => (1 - _animatedValue) * 2 * -widget.barHeight;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(children: [
          widget.child,

          /// TITLE APPBAR
          SizedBox(
              height: widget.barHeight,
              child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                        offset: Offset(0, _barHeightOffset),
                        child: AppBar(
                            backgroundColor:
                                DynamicTheme.get(context).background(),
                            elevation: 2.r * _animatedValue,
                            shadowColor: DynamicTheme.get(context).background(),
                            titleSpacing: 0.0,
                            centerTitle: widget.centerTitle,
                            title: widget.title,
                            actions: widget.actions));
                  })),
        ]));
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      if (!_animationController.isAnimating) {
        if (notification.metrics.pixels >= widget.barHeight * 2) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
