import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class FeedTitleBar extends StatelessWidget {
  const FeedTitleBar({
    Key? key,
    required this.title,
    this.titleTextStyle,
    this.padding = EdgeInsets.zero,
    this.trailing,
  }) : super(key: key);

  final String title;
  final TextStyle? titleTextStyle;
  final EdgeInsets padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        height: ComponentSize.small.h,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          /// TITLE
          Expanded(
              child: Container(
                  alignment: Alignment.bottomLeft,
                  height: ComponentSize.small.h,
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleTextStyle ?? TextStyles.boldHeading2))),

          /// OPTIONAL TRAILING WIDGET
          if (trailing != null) trailing!,
        ]));
  }
}
