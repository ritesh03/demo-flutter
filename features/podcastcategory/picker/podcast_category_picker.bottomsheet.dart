import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/app_bottomsheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import 'podcast_category_picker.model.dart';
import 'podcast_category_picker_item.widget.dart';

class PodcastCategoryPickerArgs {
  PodcastCategoryPickerArgs({
    required this.selectedCategories,
  });

  final List<PodcastCategory> selectedCategories;
}

class PodcastCategoryPickerBottomSheet extends StatefulWidget {
  //=
  static Future<PodcastCategoryPickerArgs?> show(
      BuildContext context, PodcastCategoryPickerArgs args) {
    return AppBottomSheet.show<PodcastCategoryPickerArgs?,
        PodcastCategoryPickerModel>(
      context,
      changeNotifier: PodcastCategoryPickerModel(args: args),
      builder: (context, controller) {
        return PodcastCategoryPickerBottomSheet(controller: controller);
      },
    );
  }

  const PodcastCategoryPickerBottomSheet({
    Key? key,
    this.controller,
  }) : super(key: key);

  final ScrollController? controller;

  @override
  State<PodcastCategoryPickerBottomSheet> createState() =>
      _PodcastCategoryPickerBottomSheetState();
}

class _PodcastCategoryPickerBottomSheetState
    extends State<PodcastCategoryPickerBottomSheet> {
  //=

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      modelOf(context).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.medium.h),
      Expanded(child: _buildPodcastCategories()),
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

  Widget _buildClearSelectedCategoriesButton() {
    return Selector<PodcastCategoryPickerModel, bool>(
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
    return Selector<PodcastCategoryPickerModel, bool>(
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

  Widget _buildPodcastCategories() {
    return Selector<PodcastCategoryPickerModel, Result<List<PodcastCategory>>?>(
        selector: (_, model) => model.podcastCategoriesResult,
        builder: (_, result, __) {
          //=

          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
                error: result.error(),
                onTryAgain: () {
                  modelOf(context).fetchPodcastCategories();
                });
          }

          final categories = result.data();
          if (categories.isEmpty) {
            return const EmptyIndicator();
          }

          return ListView.builder(
              controller: widget.controller,
              itemCount: categories.length,
              itemBuilder: (_, index) =>
                  _buildPodcastCategoryItem(categories[index]));
        });
  }

  Widget _buildPodcastCategoryItem(PodcastCategory category) {
    return Selector<PodcastCategoryPickerModel, bool>(
        selector: (_, model) => model.isPodcastCategorySelected(category),
        builder: (_, isSelected, __) {
          return PodcastCategoryPickerItemWidget(
              category: category,
              isSelected: isSelected,
              onPressed: _onPodcastCategorySelected);
        });
  }

  PodcastCategoryPickerModel modelOf(BuildContext context) {
    return context.read<PodcastCategoryPickerModel>();
  }

  void _onClearSelectionButtonTapped() {
    final args = PodcastCategoryPickerArgs(selectedCategories: []);
    RootNavigation.pop(context, args);
  }

  void _onApplySelectionButtonTapped() {
    final args = PodcastCategoryPickerArgs(
        selectedCategories: modelOf(context).selectedCategories);
    RootNavigation.pop(context, args);
  }

  void _onPodcastCategorySelected(PodcastCategory category) {
    modelOf(context).toggleCategorySelection(category);
  }
}
