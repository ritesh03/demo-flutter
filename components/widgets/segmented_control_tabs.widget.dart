import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class SegmentedControlTabsWidget<T> extends StatelessWidget {
  const SegmentedControlTabsWidget({
    Key? key,
    this.height,
    required this.items,
    required this.itemTitle,
    this.margin = EdgeInsets.zero,
    required this.onChanged,
    required this.selectedItemIndex,
  }) : super(key: key);

  final double? height;
  final List<T> items;
  final String Function(T item) itemTitle;
  final EdgeInsets margin;
  final ValueChanged<T> onChanged;
  final int selectedItemIndex;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
          height: height,
          margin: margin,
          decoration: _buildTrackDecoration(context),
          clipBehavior: Clip.hardEdge,
          child: DefaultTabController(
              length: items.length,
              initialIndex: selectedItemIndex,
              child: TabBar(
                onTap: (index) => onChanged(items[index]),
                indicator: _buildIndicatorDecoration(context),
                labelColor: DynamicTheme.get(context).white(),
                labelStyle: TextStyles.boldBody,
                unselectedLabelColor: DynamicTheme.get(context).neutral10(),
                unselectedLabelStyle: TextStyles.body,
                tabs: items.map((item) {
                  return _TabItem(text: itemTitle(item));
                }).toList(),
              ))),
    );
  }
}

class ControlledSegmentedControlTabBar<T> extends StatelessWidget {
  const ControlledSegmentedControlTabBar({
    Key? key,
    required this.controller,
    this.height,
    required this.items,
    required this.itemTitle,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  final TabController controller;
  final double? height;
  final List<T> items;
  final String Function(T item) itemTitle;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        height: height,
        margin: margin,
        decoration: _buildTrackDecoration(context),
        clipBehavior: Clip.hardEdge,
        child: TabBar(
          controller: controller,
          indicator: _buildIndicatorDecoration(context),
          labelColor: DynamicTheme.get(context).white(),
          labelStyle: TextStyles.boldBody,
          unselectedLabelColor: DynamicTheme.get(context).neutral10(),
          unselectedLabelStyle: TextStyles.body,
          tabs: items.map((item) {
            return _TabItem(text: itemTitle(item));
          }).toList(),
        ),
      ),
    );
  }
}


Decoration _buildTrackDecoration(BuildContext context) {
  return BoxDecoration(
      color: DynamicTheme.get(context).black(),
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r));
}

Decoration _buildIndicatorDecoration(BuildContext context) {
  return BoxDecoration(
      color: DynamicTheme.get(context).secondary40(),
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r));
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        child: Tab(text: text));
  }
}
