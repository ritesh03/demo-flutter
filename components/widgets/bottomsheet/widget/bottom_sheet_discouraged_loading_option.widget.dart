import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';

class BottomSheetDiscouragedLoadingOption extends StatelessWidget {
  const BottomSheetDiscouragedLoadingOption({
    Key? key,
    required this.text,
    this.margin,
  }) : super(key: key);

  final String text;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final itemHeight = ComponentSize.large.h;
    final iconSize = ComponentSize.large.h;

    final textColor = DynamicTheme.get(context).neutral10();

    return Container(
        height: itemHeight,
        margin: margin,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
              width: iconSize,
              height: iconSize,
              child: LoadingIndicator(size: ComponentSize.smaller.r)),
          Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.body.copyWith(color: textColor))
        ]));
  }
}
