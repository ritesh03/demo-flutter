import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/chip/chip.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/textfield/search/searchbar.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/skit/filter/sort/skit_sort_order_tile.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'skit_filters.model.dart';
import 'sort/skit_sort_options.bottomsheet.dart';

class SkitFilterSelectionArgs {
  SkitFilterSelectionArgs({
    required this.filter,
  });

  final SkitFilter filter;
}

class SkitFiltersBottomSheet extends StatefulWidget {
  //=
  static Future<SkitFilterSelectionArgs?> show(
    BuildContext context,
    SkitFilterSelectionArgs args,
  ) {
    return showMaterialBottomSheet<SkitFilterSelectionArgs?>(
      context,
      builder: (context, controller) {
        return ChangeNotifierProvider(
            create: (_) => SkitFiltersModel(args: args),
            child: SkitFiltersBottomSheet(controller: controller));
      },
    );
  }

  const SkitFiltersBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<SkitFiltersBottomSheet> createState() => _SkitFiltersBottomSheetState();
}

class _SkitFiltersBottomSheetState extends State<SkitFiltersBottomSheet> {
  //=

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      modelOf(context).fetchSkitCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      SizedBox(height: ComponentInset.normal.h),
      Expanded(child: _buildSkitCategories()),
      _buildSortOptionTile(),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        height: ComponentSize.smaller.h,
        child: Stack(children: [
          Positioned.fill(
              child: Text(LocaleResources.of(context).categories,
                  style: TextStyles.boldBody, textAlign: TextAlign.center)),
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildClearSelectedCategoriesButton()),
          Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildApplySelectedCategoriesButton()),
        ]));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          backgroundColor: DynamicTheme.get(context).background(),
          hintText: LocaleResources.of(context).search,
          onQueryChanged: modelOf(context).updateSearchQuery,
          onQueryCleared: modelOf(context).clearSearchQuery),
    );
  }

  Widget _buildClearSelectedCategoriesButton() {
    return Selector<SkitFiltersModel, bool>(
        selector: (_, model) => model.canClearSelection(),
        builder: (_, canClearSelection, __) {
          if (!canClearSelection) return Container();

          return AppIconTextButton(
              color: DynamicTheme.get(context).neutral10(),
              height: ComponentSize.smaller.h,
              iconPath: Assets.iconResetMedium,
              text: LocaleResources.of(context).clear,
              onPressed: _onClearSelectionButtonTapped);
        });
  }

  Widget _buildApplySelectedCategoriesButton() {
    return Selector<SkitFiltersModel, bool>(
        selector: (_, model) => model.canApplySelection(),
        builder: (_, canApplySelection, __) {
          if (!canApplySelection) return Container();

          return Button(
              height: ComponentSize.smaller.h,
              text: LocaleResources.of(context).apply,
              type: ButtonType.text,
              onPressed: _onApplySelectionButtonTapped);
        });
  }

  Widget _buildSkitCategories() {
    return Selector<SkitFiltersModel, Result<List<SkitCategory>>?>(
        selector: (_, model) => model.categoriesResult,
        builder: (_, result, __) {
          //=

          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
                error: result.error(),
                onTryAgain: () {
                  modelOf(context).fetchSkitCategories();
                });
          }

          final categories = result.data();
          if (categories.isEmpty) {
            return const EmptyIndicator();
          }

          return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(ComponentInset.normal.r),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: ComponentInset.normal.r,
                    runSpacing: ComponentInset.normal.r,
                    children: categories.map(_buildSkitCategoryChip).toList()),
              ));
        });
  }

  Widget _buildSkitCategoryChip(SkitCategory category) {
    return Selector<SkitFiltersModel, bool>(
        selector: (_, model) => model.isCategorySelected(category),
        builder: (_, isSelected, __) {
          return ChipWidget(
            data: category,
            text: category.title,
            selected: isSelected,
            onPressed: (_) => _onSkitCategorySelected(category),
          );
        });
  }

  Widget _buildSortOptionTile() {
    return Selector<SkitFiltersModel, Tuple2<bool, SkitSortOrder>>(
        selector: (_, model) =>
            Tuple2(model.canChangeSortOption(), model.selectedSortOrder),
        builder: (_, tuple, __) {
          final canSort = tuple.item1;
          if (!canSort) return Container();

          final sortOrder = tuple.item2;
          return SkitSortOrderTile(
              sortOrder: sortOrder, onTap: _onSortButtonTapped);
        });
  }

  SkitFiltersModel modelOf(BuildContext context) {
    return context.read<SkitFiltersModel>();
  }

  void _onClearSelectionButtonTapped() {
    final args = SkitFilterSelectionArgs(filter: SkitFilter());
    RootNavigation.pop(context, args);
  }

  void _onApplySelectionButtonTapped() {
    final args =
        SkitFilterSelectionArgs(filter: modelOf(context).selectedFilter);
    RootNavigation.pop(context, args);
  }

  void _onSkitCategorySelected(SkitCategory category) {
    modelOf(context).toggleCategorySelection(category);
  }

  void _onSortButtonTapped() async {
    hideKeyboard(context);

    final updatedSortOrder = await SkitSortOptionsBottomSheet.show(
      context,
      sortOrder: modelOf(context).selectedSortOrder,
    );

    if (!mounted) return;
    if (updatedSortOrder != null) {
      modelOf(context).setSortOrder(updatedSortOrder);
    }
  }
}
