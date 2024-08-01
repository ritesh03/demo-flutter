import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/textfield/widget/icon_prefix.widget.dart';
import 'package:kwotmusic/util/debounce.dart';
import 'package:kwotmusic/util/keyboard_visibility_notifier.dart';
import 'package:kwotmusic/util/util.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    this.controller,
    this.backgroundColor,
    this.focusNode,
    required this.hintText,
    this.margin = EdgeInsets.zero,
    this.suffixes = const [],
    this.onQuerySubmitted,
    this.onQueryChanged,
    this.onQueryCleared,
  }) : super(key: key);

  final TextEditingController? controller;
  final Color? backgroundColor;
  final FocusNode? focusNode;
  final String hintText;
  final EdgeInsets margin;
  final List<Widget> suffixes;
  final ValueSetter<String>? onQuerySubmitted;
  final ValueChanged<String>? onQueryChanged;
  final VoidCallback? onQueryCleared;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _textController;
  late final ValueNotifier<bool> _hasInputNotifier;

  late final KeyboardVisibilityNotifier _keyboardVisibilityNotifier;
  late final Debounce _searchDebounce;

  @override
  void initState() {
    super.initState();

    _textController = widget.controller ?? TextEditingController();
    _hasInputNotifier = ValueNotifier(false);

    _textController.addListener(_listenToTextController);

    _keyboardVisibilityNotifier = KeyboardVisibilityNotifier()..init(context);
    _searchDebounce = Debounce(duration: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return TextInputField(
        controller: _textController,
        defaultBackgroundColor: widget.backgroundColor,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        hasLabel: false,
        margin: widget.margin,
        maxLength: AppConfig.allowedSearchQueryLength,
        textInputAction: TextInputAction.search,
        onChanged: (text) {
          _searchDebounce.run(() {
            widget.onQueryChanged?.call(text);
          });
        },
        onSubmitted: (text) {
          _searchDebounce.cancel();
          widget.onQuerySubmitted?.call(text);
        },
        prefixes: [
          IconPrefix(
            iconPath: Assets.iconSearch,
            iconColor: DynamicTheme.get(context).neutral10(),
          )
        ],
        suffixes: [
          _buildClearInputSuffix(context),
          for (final suffix in widget.suffixes) suffix,
        ]);
  }

  @override
  void dispose() {
    _textController.removeListener(_listenToTextController);
    _hasInputNotifier.dispose();

    _keyboardVisibilityNotifier.dispose();
    _searchDebounce.cancel();
    super.dispose();
  }

  Widget _buildClearInputSuffix(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _hasInputNotifier,
        builder: (_, hasInput, __) {
          if (!hasInput) return Container();
          return ScaleTap(
              onPressed: _onClearInputButtonTapped,
              child: Container(
                  color: Colors.transparent,
                  width: ComponentSize.normal.w,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    Assets.iconCrossBold,
                    width: ComponentSize.smallest.r,
                    height: ComponentSize.smallest.r,
                    color: DynamicTheme.get(context).white(),
                  )));
        });
  }

  void _listenToTextController() {
    _hasInputNotifier.value = _textController.text.isNotEmpty;
  }

  void _onClearInputButtonTapped() {
    _textController.clear();
    hideKeyboard(context);
    _searchDebounce.cancel();
    widget.onQueryCleared?.call();
  }
}
