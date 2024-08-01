import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/segmented_control_tabs.widget.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/skit/filter/skit_filters.bottomsheet.dart';
import 'package:kwotmusic/features/skit/filter/skit_list_filter_row.widget.dart';
import 'package:kwotmusic/features/skit/options/skit_options.bottomsheet.dart';
import 'package:kwotmusic/features/skit/options/skit_options.model.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';
import 'package:kwotmusic/features/skit/widget/audio_skit_list_item.widget.dart';
import 'package:kwotmusic/features/skit/widget/video_skit_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'skits.model.dart';

class SkitsPage extends StatefulWidget {
  const SkitsPage({Key? key}) : super(key: key);

  @override
  State<SkitsPage> createState() => _SkitsPageState();
}

class _SkitsPageState extends PageState<SkitsPage> {
  //=

  @override
  void initState() {
    super.initState();
    skitsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: ItemListWidget<Skit, SkitsModel>(
                columnItemSpacing: ComponentInset.normal.h,
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
                footerSlivers: [DashboardConfigAwareFooter.asSliver()],
                itemBuilder: (context, skit, index) {
                  return _buildSkitItem(index, skit);
                })));
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  /*
   * HEADER
   */

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      _buildSelectedFilterRow(),
      SizedBox(height: ComponentInset.medium.h),
      _buildSkitTypeChooser(),
      SizedBox(height: ComponentInset.medium.h),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<SkitsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).skits,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).skitsSearchHint,
          onQueryChanged: skitsModelOf(context).updateSearchQuery,
          onQueryCleared: skitsModelOf(context).clearSearchQuery,
          suffixes: [_buildFilterIconWidget()],
        ));
  }

  Widget _buildFilterIconWidget() {
    return Selector<SkitsModel, bool>(
        selector: (_, model) => model.isFilterApplied,
        builder: (_, areFiltersApplied, __) {
          return FilterIconSuffix(
            isSelected: areFiltersApplied,
            onPressed: _onFilterButtonTapped,
          );
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<SkitsModel, SkitFilter>(
        selector: (_, model) => model.skitFilter,
        builder: (_, skitFilter, __) {
          if (skitFilter.isDefault) {
            return Container();
          }

          return SkitListFilterRow(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              skitFilter: skitFilter,
              onRemoveCategory: (category) {
                skitsModelOf(context).removeSelectedCategory(category);
              },
              onResetSortOrder: skitsModelOf(context).resetSortOrder);
        });
  }

  Widget _buildSkitTypeChooser() {
    return Selector<SkitsModel, SkitType>(
        selector: (_, model) => model.selectedSkitType,
        builder: (_, skitType, __) {
          final skitActionsModel = locator<SkitActionsModel>();
          return SegmentedControlTabsWidget<SkitType>(
              height: ComponentSize.normal.h,
              items: SkitType.values.toList(),
              itemTitle: (type) =>
                  skitActionsModel.getSkitTypeText(context, type: type),
              onChanged: (skitType) {
                skitsModelOf(context).setSelectedSkitType(skitType);
              },
              margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
              selectedItemIndex: SkitType.values.indexOf(skitType));
        });
  }

  Widget _buildSkitItem(int index, Skit skit) {
    switch (skit.type) {
      case SkitType.audio:
        return AudioSkitListItem(
          skit: skit,
          onTap: _onSkitTapped,
          onOptionsTap: _onSkitOptionsTapped,
        );
      case SkitType.video:
        return VideoSkitListItem(
          skit: skit,
          onTap: _onSkitTapped,
          onOptionsTap: _onSkitOptionsTapped,
        );
    }
  }

  SkitsModel skitsModelOf(BuildContext context) {
    return context.read<SkitsModel>();
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final args = skitsModelOf(context).createSkitCategoryPickerArgs();
    final updatedArgs = await SkitFiltersBottomSheet.show(context, args);

    if (!mounted) return;
    if (updatedArgs != null) {
      skitsModelOf(context).setSelectedFilter(updatedArgs.filter);
    }
  }

  void _onSkitTapped(Skit skit) {
    hideKeyboard(context);
    locator<FeedRouting>().showSkitDetailPage(context, skit: skit);
  }

  void _onSkitOptionsTapped(Skit skit) {
    hideKeyboard(context);

    final args = SkitOptionsArgs(skit: skit);
    SkitOptionsBottomSheet.show(context, args: args);
  }
}
