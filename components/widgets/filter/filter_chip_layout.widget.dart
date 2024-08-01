import 'package:flutter/material.dart'  hide SearchBar;
import 'package:great_list_view/great_list_view.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip.widget.dart';

class FilterChipItem {
  FilterChipItem({
    required this.text,
    required this.action,
  });

  final String text;
  final VoidCallback action;
}

class FilterChipLayout extends StatefulWidget {
  const FilterChipLayout({
    Key? key,
    required this.items,
    this.listController,
    this.scrollController,
    this.margin,
    this.padding,
  }) : super(key: key);

  final List<FilterChipItem> items;
  final AnimatedListController? listController;
  final ScrollController? scrollController;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  State<FilterChipLayout> createState() => _FilterChipLayoutState();
}

class _FilterChipLayoutState extends State<FilterChipLayout> {
  late AnimatedListController _listController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _listController = widget.listController ?? AnimatedListController();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: ComponentSize.small.h,
        margin: widget.margin,
        child: AutomaticAnimatedListView<FilterChipItem>(
          list: widget.items,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: widget.padding ??
              EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
          comparator: AnimatedListDiffListComparator<FilterChipItem>(
              sameItem: (a, b) => a.text == b.text,
              sameContent: (a, b) => a.text == b.text),
          itemBuilder: (context, item, data) => _buildItem(item),
          listController: _listController,
          scrollController: _scrollController,
        ));
  }

  Widget _buildItem(FilterChipItem item) {
    return FilterChipWidget(
        title: item.text,
        iconPath: Assets.iconCrossBold,
        margin: EdgeInsets.only(right: ComponentInset.small.w),
        onIconTap: item.action);
  }
}
