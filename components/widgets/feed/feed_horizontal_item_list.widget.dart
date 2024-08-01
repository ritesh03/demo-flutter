import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/indicator/empty_indicator.widget.dart';

import 'dependant_height_adjustment.dart';

class FeedHorizontalItemList extends StatelessWidget {
  const FeedHorizontalItemList({
    Key? key,
    required this.itemCount,
    required this.itemSpacing,
    required this.widgetBuilder,
  }) : super(key: key);

  final int itemCount;
  final double itemSpacing;
  final IndexedWidgetBuilder widgetBuilder;

  @override
  Widget build(BuildContext context) {
    //=
    if (itemCount == 0) {
      return const EmptyIndicator();
    }
    return DependantHeightAdjustment(
        source: widgetBuilder(context, 0 /* first-index */),
        target: ListView.separated(
          itemBuilder: widgetBuilder,
          itemCount: itemCount,
          padding: EdgeInsets.symmetric(horizontal: itemSpacing),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
          shrinkWrap: true,
        ),
        targetWidth: MediaQuery.of(context).size.width);
  }
}
