import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class ContactReasonItemWidget extends StatelessWidget {
  const ContactReasonItemWidget({
    Key? key,
    required this.reason,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  final ContactReason reason;
  final bool isSelected;
  final Function(ContactReason reason) onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () => onPressed(reason),
      child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: DynamicTheme.get(context).black(),
            border: Border.all(color: obtainBorderColor(context)),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
          padding: EdgeInsets.all(ComponentInset.normal.r),
          clipBehavior: Clip.antiAlias,
          child: _buildName(context)),
    );
  }

  Widget _buildName(BuildContext context) {
    return Text(reason.title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body.copyWith(
          color: obtainForegroundColor(context),
        ));
  }

  Color obtainBorderColor(BuildContext context) {
    return isSelected ? DynamicTheme.get(context).white() : Colors.transparent;
  }

  Color obtainForegroundColor(BuildContext context) {
    return isSelected
        ? DynamicTheme.get(context).white()
        : DynamicTheme.get(context).neutral20();
  }
}
