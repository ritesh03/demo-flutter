import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';

class ChipWidget<T> extends StatelessWidget {
  const ChipWidget({
    Key? key,
    required this.data,
    required this.text,
    required this.selected,
    this.size = ChipSize.normal,
    this.margin = EdgeInsets.zero,
    required this.onPressed,
  }) : super(key: key);

  final T data;
  final String text;
  final bool selected;
  final ChipSize size;
  final EdgeInsets margin;
  final Function(T data) onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onPressed(data),
        child: Container(
          height: obtainHeight(),
          decoration: BoxDecoration(
              color: obtainBackgroundColor(context),
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          margin: margin,
          padding: EdgeInsets.symmetric(horizontal: obtainHorizontalPadding()),
          child: Stack(alignment: Alignment.center, children: [
            Opacity(opacity: 0.0, child: _buildPseudoSelectionTextWidget()),
            Text(text, style: obtainTextStyle(context)),
          ]),
        ));
  }

  /// This function is used to make chip-widget long enough for [selected]
  /// state when font style changes from PLAIN to BOLD. This way
  /// its width stays the same for all [selected] states.
  ///
  /// Without this, selecting a chip will cause other chips
  /// in horizontal scroll to shift or change positions.
  Widget _buildPseudoSelectionTextWidget() {
    return Text(text, style: TextStyles.boldBody);
  }

  Color obtainBackgroundColor(BuildContext context) {
    return selected
        ? DynamicTheme.get(context).secondary100()
        : DynamicTheme.get(context).black();
  }

  double obtainHeight() {
    switch (size) {
      case ChipSize.normal:
        return ComponentSize.normal.h;
      case ChipSize.small:
        return ComponentSize.smaller.h;
    }
  }

  double obtainHorizontalPadding() {
    return ComponentInset.normal.r;
  }

  TextStyle obtainTextStyle(BuildContext context) {
    final textColor = selected
        ? DynamicTheme.get(context).black()
        : DynamicTheme.get(context).white();

    switch (size) {
      case ChipSize.normal:
        return selected
            ? TextStyles.boldBody.copyWith(color: textColor)
            : TextStyles.body.copyWith(color: textColor);

      case ChipSize.small:
        return TextStyles.boldHeading6.copyWith(color: textColor);
    }
  }
}
