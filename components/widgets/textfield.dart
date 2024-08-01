import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/marquee/marquee.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:provider/provider.dart';

export 'textfield/search/comment_input.widget.dart';
export 'textfield/search/searchbar.widget.dart';
export 'textfield/widget/country_code_prefix.widget.dart';
export 'textfield/widget/filter_icon_suffix.widget.dart';
export 'textfield/widget/password_visibility_toggle_suffix.widget.dart';

class _TextInputFieldModel with ChangeNotifier {
  bool _isFocused = false;

  bool get isFocused => _isFocused;

  void onFocusChange(bool isFocused) {
    _isFocused = isFocused;
    notifyListeners();
  }
}

class TextInputField extends StatelessWidget {
  const TextInputField({
    Key? key,
    this.width,
    this.height,
    required this.controller,
    this.defaultBackgroundColor,
    this.enabled = true,
    this.errorText,
    this.focusNode,
    this.hasLabel = true,
    required this.hintText,
    this.initialText,
    this.inputBoxCrossAxisAlignment,
    this.inputBoxPadding,
    this.inputFormatters,
    this.keyboardType,
    this.labelText,
    this.maxLength,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.margin = EdgeInsets.zero,
    this.onChanged,
    this.onSubmitted,
    this.isPassword,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.showShadow = false,
    this.prefixes = const [],
    this.suffixes = const [],
  }) : super(key: key);

  final double? width;
  final double? height;
  final TextEditingController controller;
  final Color? defaultBackgroundColor;
  final bool enabled;
  final String? errorText;
  final FocusNode? focusNode;
  final bool hasLabel;
  final String hintText;
  final String? initialText;
  final CrossAxisAlignment? inputBoxCrossAxisAlignment;
  final EdgeInsets? inputBoxPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? labelText;
  final EdgeInsets margin;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueSetter<String>? onSubmitted;
  final bool? isPassword;
  final List<Widget> prefixes;
  final List<Widget> suffixes;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => _TextInputFieldModel(),
        builder: (context, __) {
          return _buildContent(context);
        });
  }

  Widget _buildContent(BuildContext context) {
    final inputBoxPadding = this.inputBoxPadding ?? EdgeInsets.zero;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLabel) _buildLabel(context),
          if (hasLabel) SizedBox(height: 2.h),
          Container(
              width: width,
              height: obtainHeight(),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: obtainBackgroundColor(context),
                  borderRadius: obtainBorderRadius(),
                  boxShadow: obtainBoxShadow(context)),
              margin: margin,
              child: Stack(children: [
                Positioned.fill(
                  child: Padding(
                    padding: inputBoxPadding,
                    child: Row(
                        crossAxisAlignment: inputBoxCrossAxisAlignment ??
                            CrossAxisAlignment.center,
                        children: [
                          for (final prefix in prefixes) prefix,
                          Expanded(child: _buildInputField(context)),
                          for (final suffix in suffixes) suffix,
                        ]),
                  ),
                ),
                Positioned.fill(child: _buildInputBorder(context))
              ]))
        ]);
  }

  Widget _buildLabel(BuildContext context) {
    return Container(
        height: ComponentSize.smallest.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        child: Marquee(
          text: obtainLabelText(),
          style: TextStyles.heading6.copyWith(
            color: obtainLabelColor(context),
          ),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0,
          velocity: 100.0,
          accelerationDuration: const Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ));
  }

  Widget _buildInputBorder(BuildContext context) {
    return IgnorePointer(
        child: Selector<_TextInputFieldModel, bool>(
            selector: (_, model) => model.isFocused,
            builder: (_, isFocused, __) {
              if (!isFocused) return Container();

              return Container(
                  decoration: BoxDecoration(
                      borderRadius: obtainBorderRadius(),
                      border: Border.all(
                        color: obtainFocusedBorderColor(context),
                        width: obtainBorderWidth(),
                      )));
            }));
  }

  Widget _buildInputField(BuildContext context) {
    const border = OutlineInputBorder(
        borderSide: BorderSide(width: 0, color: Colors.transparent));

    return Focus(
      onFocusChange: context.read<_TextInputFieldModel>().onFocusChange,
      child: TextFormField(
        autocorrect: false,
        controller: controller,
        cursorColor: DynamicTheme.get(context).white(),
        cursorWidth: obtainCursorWidth(),
        decoration: InputDecoration(
          contentPadding: obtainContentPadding(context),
          counterText: "",
          focusedBorder: border,
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          enabled: enabled,
          hintMaxLines: 1,
          hintStyle:
              TextStyles.heading5.copyWith(color: obtainHintColor(context)),
          hintText: hintText,
        ),
        enabled: enabled,
        enableSuggestions: false,
        focusNode: focusNode,
        initialValue: initialText,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        maxLines: maxLines,
        minLines: minLines,
        obscureText: isPassword ?? false,
        obscuringCharacter: "●",
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        style: TextStyles.heading5.copyWith(color: obtainTextColor(context)),
        textAlign: textAlign,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
      ),
    );
  }

  Color obtainBackgroundColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).error100();
    }

    return enabled
        ? defaultBackgroundColor ?? DynamicTheme.get(context).neutral80()
        : DynamicTheme.get(context).black();
  }

  BorderRadius obtainBorderRadius() {
    return BorderRadius.circular(ComponentRadius.normal.r);
  }

  List<BoxShadow>? obtainBoxShadow(BuildContext context) {
    if (enabled && showShadow) {
      return const [
        BoxShadow(
            // TODO: Perhaps use a neutral color for shadow
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0)
      ];
    }

    return null;
  }

  double obtainBorderWidth() {
    return 2.w;
  }

  EdgeInsets obtainContentPadding(BuildContext context) {
    final horizontalPadding = ComponentInset.normal.w;

    return EdgeInsets.only(
      left: prefixes.isEmpty ? horizontalPadding : 0,
      right: suffixes.isEmpty ? horizontalPadding : 0,
    );
  }

  double obtainCursorWidth() {
    return 2.w;
  }

  Color obtainFocusedBorderColor(BuildContext context) {
    if (errorText != null) {
      return Colors.transparent;
    }

    return DynamicTheme.get(context).secondary100();
  }

  double obtainHeight() {
    return height ?? ComponentSize.normal.h;
  }

  Color obtainHintColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).white();
    }

    return enabled
        ? DynamicTheme.get(context).neutral20()
        : DynamicTheme.get(context).neutral60();
  }

  String obtainLabelText() {
    // Show errorText as label if not null.
    if (errorText != null) {
      return errorText!;
    }

    return labelText!;
  }

  Color obtainLabelColor(BuildContext context) {
    if (errorText != null) {
      return DynamicTheme.get(context).error100();
    }

    return DynamicTheme.get(context).neutral40();
  }

  Color obtainTextColor(BuildContext context) {
    return DynamicTheme.get(context).white();
  }
}

class PinInputField extends StatelessWidget {
  const PinInputField({
    Key? key,
    this.height,
    this.padding = EdgeInsets.zero,
    required this.pinLength,
    required this.controller,
  }) : super(key: key);

  final double? height;
  final EdgeInsets padding;
  final int pinLength;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? ComponentSize.normal.h,
        padding: padding,
        child: PinInputTextField(
          pinLength: pinLength,
          decoration: BoxLooseDecoration(
              bgColorBuilder:
                  FixedColorBuilder(DynamicTheme.get(context).neutral80()),
              radius: Radius.circular(ComponentRadius.small),
              strokeWidth: 2.w,
              strokeColorBuilder: PinListenColorBuilder(
                DynamicTheme.get(context).secondary100(),
                Colors.transparent,
              ),
              textStyle: TextStyles.boldHeading3),
          controller: controller,
        ));
  }
}
