import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';

// TODO: Disabled State (Checked: true/false)
class KCheckBox extends StatelessWidget {
  const KCheckBox({
    Key? key,
    required this.checked,
    required this.onTap,
  }) : super(key: key);

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.smaller.r;

    final backgroundColor = getBackgroundColor(context);
    final border = getBorder(context);

    return ScaleTap(
      onPressed: onTap,
      child: Container(
        alignment: Alignment.center,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.circular(ComponentRadius.small.r),
        ),
        child: checked
            ? _CheckedBoxIndicator(
                borderRadius: BorderRadius.circular(ComponentRadius.smaller.r),
                size: size / 2,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Color getBackgroundColor(BuildContext context) {
    return checked
        ? DynamicTheme.get(context).secondary100()
        : Colors.transparent;
  }

  Border? getBorder(BuildContext context) {
    return checked
        ? null
        : Border.all(
            color: DynamicTheme.get(context).secondary60(),
            width: 2.r,
          );
  }
}

class _CheckedBoxIndicator extends StatelessWidget {
  const _CheckedBoxIndicator({
    Key? key,
    required this.size,
    required this.borderRadius,
  }) : super(key: key);

  final double size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DynamicTheme.get(context).white(),
        borderRadius: borderRadius,
      ),
    );
  }
}
