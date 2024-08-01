import 'dart:math';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'dependant_height_adjustment.dart';
import 'feed_vertical_item_list.widget.dart';

class FeedVerticallyGroupedHorizontalPageList extends StatelessWidget {
  //=
  const FeedVerticallyGroupedHorizontalPageList({
    Key? key,
    required this.itemCount,
    required this.itemSpacing,
    this.itemsPerGroup = 4,
    this.itemWidth,
    required this.widgetBuilder,
  }) : super(key: key);

  final int itemCount;
  final double itemSpacing;
  final int itemsPerGroup;
  final double? itemWidth;
  final IndexedWidgetBuilder widgetBuilder;

  @override
  Widget build(BuildContext context) {
    final horizontalItemCount = (itemCount / itemsPerGroup).ceil();

    return DependantHeightAdjustment(
        source: _createVerticallyGroupedItemList(context, 0 /* first-index */),
        target: PageView.builder(
            itemCount: horizontalItemCount,
            padEnds: false,
            controller: PageController(viewportFraction: 0.8, initialPage: 0),
            allowImplicitScrolling: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _createVerticallyGroupedItemList(context, index);
            }),
        targetWidth: MediaQuery.of(context).size.width);
  }

  Widget _createVerticallyGroupedItemList(
    BuildContext context,
    int horizontalItemIndex,
  ) {
    final verticalItemCount = _getVerticalItemCount(horizontalItemIndex);

    if (itemsPerGroup == 1) {
      final isLastItem = (horizontalItemIndex == itemCount - 1);
      return Container(
        width: itemWidth ?? 0.8.sw,
        padding: EdgeInsets.only(
          left: itemSpacing,

          /// last item needs padding on both sides (horizontally)
          right: isLastItem ? itemSpacing : 0,
        ),
        child: widgetBuilder(context, horizontalItemIndex),
      );
    }

    return SizedBox(
        width: itemWidth ?? 0.8.sw,
        child: FeedVerticalItemList(
            itemCount: verticalItemCount,
            padding: EdgeInsets.symmetric(horizontal: itemSpacing),
            itemSpacing: itemSpacing,
            widgetBuilder: (context, verticalItemIndex) {
              return widgetBuilder(
                  context,
                  _getAbsoluteItemIndex(
                    horizontalItemIndex,
                    verticalItemIndex,
                  ));
            }));
  }

  int _getVerticalItemCount(int horizontalItemIndex) {
    return min(
      itemsPerGroup,

      /// remaining items
      itemCount - (horizontalItemIndex * itemsPerGroup),
    );
  }

  int _getAbsoluteItemIndex(int horizontalItemIndex, int verticalItemIndex) {
    return (horizontalItemIndex * itemsPerGroup) + verticalItemIndex;
  }
}
