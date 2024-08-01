import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/toggle_switch.dart';

class BottomSheetSwitchTile extends StatelessWidget {
  const BottomSheetSwitchTile({
    Key? key,
    this.height,
    this.margin,
    this.enabled = true,
    required this.checked,
    required this.onChanged,
    required this.text,
  }) : super(key: key);

  final double? height;
  final EdgeInsets? margin;
  final bool enabled;
  final bool checked;
  final Function(bool checked) onChanged;
  final String text;

  @override
  Widget build(BuildContext context) {
    final height = this.height ?? ComponentSize.large.h;
    final textStyle =
        TextStyles.body.copyWith(color: DynamicTheme.get(context).white());

    return Container(
        margin: margin,
        child: Row(children: [
          Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle)),
          SizedBox(width: ComponentInset.small.r),
          ToggleSwitch(
              height: height,
              checked: checked,
              enabled: enabled,
              onChanged: onChanged),
        ]));
  }
}
