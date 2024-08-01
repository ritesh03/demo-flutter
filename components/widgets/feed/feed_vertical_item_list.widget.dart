import 'package:flutter/material.dart'  hide SearchBar;

class FeedVerticalItemList extends StatelessWidget {
  const FeedVerticalItemList({
    Key? key,
    required this.itemCount,
    required this.padding,
    required this.itemSpacing,
    required this.widgetBuilder,
  }) : super(key: key);

  final int itemCount;
  final EdgeInsets padding;
  final double itemSpacing;
  final IndexedWidgetBuilder widgetBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: widgetBuilder,
      itemCount: itemCount,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: itemSpacing),
      shrinkWrap: true,
    );
  }
}
