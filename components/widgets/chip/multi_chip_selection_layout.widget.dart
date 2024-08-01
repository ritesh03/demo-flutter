import 'dart:math' as math;

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/chip/chip.widget.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MultiChipSelectionLayoutWidget<T> extends StatefulWidget {
  const MultiChipSelectionLayoutWidget({
    Key? key,
    required this.height,
    required this.items,
    required this.itemTitle,
    this.itemInnerSpacing = 0,
    this.itemOuterSpacing = 0,
    required this.onItemTap,
    required this.selectedItems,
    this.size = ChipSize.normal,
  }) : super(key: key);

  final double height;
  final List<T> items;
  final String Function(T item) itemTitle;
  final double itemInnerSpacing;
  final double itemOuterSpacing;
  final List<T> Function(T) onItemTap;
  final List<T> selectedItems;
  final ChipSize size;

  @override
  State<MultiChipSelectionLayoutWidget<T>> createState() =>
      _MultiChipSelectionLayoutWidgetState<T>();
}

class _MultiChipSelectionLayoutWidgetState<T>
    extends State<MultiChipSelectionLayoutWidget<T>> {
  late List<T> selectedItems;
  late int _initialSelectedItemIndex;
  late ItemScrollController _itemScrollController;

  @override
  void initState() {
    super.initState();
    selectedItems = widget.selectedItems;
    if (selectedItems.isNotEmpty) {
      final firstSelectedItem = selectedItems.first;
      _initialSelectedItemIndex =
          math.max(widget.items.indexOf(firstSelectedItem), 0);
    } else {
      _initialSelectedItemIndex = 0;
    }

    _itemScrollController = ItemScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: ScrollablePositionedList.separated(
          scrollDirection: Axis.horizontal,
          initialScrollIndex: _initialSelectedItemIndex,
          initialAlignment: 0.4,
          padding: EdgeInsets.symmetric(horizontal: widget.itemOuterSpacing),
          itemCount: widget.items.length,
          itemScrollController: _itemScrollController,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final itemTitle = widget.itemTitle(item);

            final isSelected = (index == 0 && selectedItems.isEmpty) ||
                selectedItems.contains(item);
            return ChipWidget<T>(
                data: item,
                text: itemTitle,
                selected: isSelected,
                size: widget.size,
                onPressed: (item) => _onItemTap(item: item, index: index));
          },
          separatorBuilder: (_, __) => SizedBox(width: widget.itemInnerSpacing),
        ));
  }

  void _scrollToIndex(int index) {
    _itemScrollController.scrollTo(
      index: index,
      alignment: 0.4,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 350),
    );
  }

  void _onItemTap({
    required T item,
    required int index,
  }) {
    setState(() {
      selectedItems = widget.onItemTap(item);
      _scrollToIndex(index);
    });
  }
}
