import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_selectable_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class SkitSortOptionsBottomSheet extends StatefulWidget {
  //=
  static Future<SkitSortOrder?> show(
    BuildContext context, {
    required SkitSortOrder sortOrder,
  }) {
    return showMaterialBottomSheet<SkitSortOrder>(
      context,
      expand: false,
      builder: (_, __) => SkitSortOptionsBottomSheet(sortOrder: sortOrder),
    );
  }

  const SkitSortOptionsBottomSheet({
    Key? key,
    required this.sortOrder,
  }) : super(key: key);

  final SkitSortOrder sortOrder;

  @override
  State<SkitSortOptionsBottomSheet> createState() =>
      _SkitSortOptionsBottomSheetState();
}

class _SkitSortOptionsBottomSheetState
    extends State<SkitSortOptionsBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),

          /// SORT BY
          Text(
            localization.sortBy,
            style: TextStyles.boldBody
                .copyWith(color: DynamicTheme.get(context).white()),
          ),
          SizedBox(height: ComponentInset.medium.h),

          /// SORT BY: NEWEST TO OLDEST
          BottomSheetSelectableTile(
              text: localization.newestToOldestSortOption,
              onTap: () => _onSortOrderTapped(SkitSortOrder.newestToOldest),
              isSelected: (widget.sortOrder == SkitSortOrder.newestToOldest)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: OLDEST TO NEWEST
          BottomSheetSelectableTile(
              text: localization.oldestToNewestSortOption,
              onTap: () => _onSortOrderTapped(SkitSortOrder.oldestToNewest),
              isSelected: (widget.sortOrder == SkitSortOrder.oldestToNewest)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: MOST POPULAR FIRST
          BottomSheetSelectableTile(
              text: localization.mostPopularFirstSortOption,
              onTap: () => _onSortOrderTapped(SkitSortOrder.mostPopularFirst),
              isSelected: (widget.sortOrder == SkitSortOrder.mostPopularFirst)),
          SizedBox(height: ComponentInset.normal.h),
        ]));
  }

  void _onSortOrderTapped(SkitSortOrder sortOrder) {
    RootNavigation.pop(context, sortOrder);
  }
}
