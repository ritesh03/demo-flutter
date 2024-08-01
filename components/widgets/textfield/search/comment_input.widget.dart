import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/textfield/widget/icon_prefix.widget.dart';
import 'package:kwotmusic/util/keyboard_visibility_notifier.dart';
import 'package:kwotmusic/util/util.dart';

class CommentInputWidget extends StatefulWidget {
  const CommentInputWidget({
    Key? key,
    this.controller,
    this.backgroundColor,
    this.height,
    required this.hintText,
    this.inputFormatters,
    this.margin = EdgeInsets.zero,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onSubmitted,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController? controller;
  final Color? backgroundColor;
  final double? height;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets margin;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueSetter<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  late final TextEditingController _textController;

  late final KeyboardVisibilityNotifier _keyboardVisibilityNotifier;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _keyboardVisibilityNotifier = KeyboardVisibilityNotifier()..init(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextInputField(
        controller: _textController,
        defaultBackgroundColor: widget.backgroundColor,
        hasLabel: false,
        height: widget.height,
        hintText: widget.hintText,
        margin: widget.margin,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        maxLines: 1,
        textInputAction: TextInputAction.done,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: _onSubmitTap,
        suffixes: [
          ScaleTap(
              onPressed: () => _onSubmitTap(_textController.text),
              child: Container(
                  color: Colors.transparent,
                  child: IconPrefix(
                      iconPath: Assets.iconSend,
                      iconColor: DynamicTheme.get(context).neutral20()))),
        ]);
  }

  @override
  void dispose() {
    _keyboardVisibilityNotifier.dispose();
    super.dispose();
  }

  void _onSubmitTap(String text) {
    widget.onSubmitted?.call(text);
    hideKeyboard(context);
  }
}
