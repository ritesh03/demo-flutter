import 'dart:math';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'feed_horizontal_item_list.widget.dart';
import 'feed_vertical_item_list.widget.dart';

class FeedVerticallyGroupedHorizontalItemList extends StatelessWidget {
  static const _itemCountPerGroup = 4;

  const FeedVerticallyGroupedHorizontalItemList({
    Key? key,
    required this.itemCount,
    required this.itemSpacing,
    this.itemWidth,
    required this.widgetBuilder,
  }) : super(key: key);

  final int itemCount;
  final double itemSpacing;
  final double? itemWidth;
  final IndexedWidgetBuilder widgetBuilder;

  @override
  Widget build(BuildContext context) {
    final horizontalItemCount = (itemCount / _itemCountPerGroup).ceil();
    return FeedHorizontalItemList(
        itemCount: horizontalItemCount,
        itemSpacing: 0,
        widgetBuilder: (_, horizontalItemIndex) {
          return _createVerticallyGroupedItemList(horizontalItemIndex);
        });
  }

  Widget _createVerticallyGroupedItemList(int horizontalItemIndex) {
    final verticalItemCount = _getVerticalItemCount(horizontalItemIndex);
    return SizedBox(
        width: itemWidth ?? 0.75.sw,
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
      _itemCountPerGroup,

      /// remaining items
      itemCount - (horizontalItemIndex * _itemCountPerGroup),
    );
  }

  int _getAbsoluteItemIndex(int horizontalItemIndex, int verticalItemIndex) {
    return (horizontalItemIndex * _itemCountPerGroup) + verticalItemIndex;
  }
}
