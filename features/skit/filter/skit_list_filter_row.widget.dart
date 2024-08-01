import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';

class SkitListFilterRow extends StatelessWidget {
  const SkitListFilterRow({
    Key? key,
    required this.skitFilter,
    required this.onRemoveCategory,
    required this.onResetSortOrder,
    this.margin,
  }) : super(key: key);

  final SkitFilter skitFilter;
  final Function(SkitCategory category) onRemoveCategory;
  final VoidCallback onResetSortOrder;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FilterChipLayout(
      items: _createItems(context),
      margin: margin,
    );
  }

  List<FilterChipItem> _createItems(BuildContext context) {
    final items = List<FilterChipItem>.empty(growable: true);
    final categoryItems = skitFilter.categories.map((category) {
      return FilterChipItem(
          text: category.title, action: () => onRemoveCategory(category));
    }).toList();
    items.addAll(categoryItems);

    if (skitFilter.sortOrder != SkitFilter.defaultSortOrder) {
      final item = FilterChipItem(
          text: locator<SkitActionsModel>()
              .getSkitSortOrderText(context, skitFilter.sortOrder),
          action: onResetSortOrder);
      items.add(item);
    }
    return items;
  }
}
