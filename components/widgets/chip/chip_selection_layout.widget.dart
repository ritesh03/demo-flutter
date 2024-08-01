import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/chip/chip.widget.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChipSelectionLayoutWidget<T> extends StatefulWidget {
  const ChipSelectionLayoutWidget({
    Key? key,
    required this.height,
    required this.items,
    required this.itemTitle,
    this.itemInnerSpacing = 0,
    this.itemOuterSpacing = 0,
    required this.onItemSelect,
    required this.selectedItem,
    this.size = ChipSize.normal,
  }) : super(key: key);

  final double height;
  final List<T> items;
  final String Function(T item) itemTitle;
  final double itemInnerSpacing;
  final double itemOuterSpacing;
  final Function(T item) onItemSelect;
  final T? selectedItem;
  final ChipSize size;

  @override
  State<ChipSelectionLayoutWidget<T>> createState() =>
      _ChipSelectionLayoutWidgetState<T>();
}

class _ChipSelectionLayoutWidgetState<T>
    extends State<ChipSelectionLayoutWidget<T>> {
  int _initialScrollItemIndex = 0;
  late ItemScrollController _itemScrollController;

  @override
  void initState() {
    super.initState();

    final selectedItem = widget.selectedItem;
    if (selectedItem != null) {
      _initialScrollItemIndex = widget.items.indexOf(selectedItem);
      if (_initialScrollItemIndex < 0) {
        _initialScrollItemIndex = 0;
      }
    }

    _itemScrollController = ItemScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: ScrollablePositionedList.separated(
          scrollDirection: Axis.horizontal,
          initialScrollIndex: _initialScrollItemIndex,
          initialAlignment: 0.4,
          padding: EdgeInsets.symmetric(horizontal: widget.itemOuterSpacing),
          itemCount: widget.items.length,
          itemScrollController: _itemScrollController,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final itemTitle = widget.itemTitle(item);
            return ChipWidget<T>(
                data: item,
                text: itemTitle,
                selected: (item == widget.selectedItem),
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
    widget.onItemSelect(item);
    _scrollToIndex(index);
  }
}
