import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kwotmusic/components/widgets/indicator/empty_indicator.widget.dart';

class FeedFixedItemsGrid extends StatelessWidget {
  const FeedFixedItemsGrid({
    Key? key,
    required this.itemCount,
    required this.columnCount,
    required this.itemSpacing,
    required this.widgetBuilder,
  }) : super(key: key);

  final int itemCount;
  final int columnCount;
  final double itemSpacing;
  final IndexedWidgetBuilder widgetBuilder;

  @override
  Widget build(BuildContext context) {
    //=
    if (itemCount == 0) {
      return const EmptyIndicator();
    }

    return AlignedGridView.count(
      crossAxisCount: columnCount,
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: itemSpacing,
      crossAxisSpacing: itemSpacing,
      padding: EdgeInsets.symmetric(horizontal: itemSpacing),
      itemBuilder: widgetBuilder,
    );
  }
}
