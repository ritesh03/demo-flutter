import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/podcast/detail/podcast_detail.model.dart';
import 'package:kwotmusic/features/podcast/filter/podcasts_filter_layout.widget.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_grid_item.widget.dart';
import 'package:kwotmusic/features/podcast/widget/podcast_list_item.widget.dart';
import 'package:kwotmusic/features/podcastcategory/picker/podcast_category_picker.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'podcasts.model.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({Key? key}) : super(key: key);

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends PageState<PodcastsPage> {
  //=

  @override
  void initState() {
    super.initState();
    podcastsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<PodcastsModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount = podcastsModelOf(context).viewColumnCount;
                  return _buildItemList(viewMode, columnCount);
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
      const Spacer(),
      _buildListViewModeSelection(),
      _buildGridViewModeSelection(),
      SizedBox(width: ComponentInset.small.w)
    ]);
  }

  Widget _buildListViewModeSelection() {
    return Selector<PodcastsModel, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return AppIconButton(
              width: ComponentSize.normal.r,
              height: ComponentSize.normal.r,
              assetColor: viewMode.isListMode
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconList,
              padding: EdgeInsets.all(ComponentInset.smaller.r),
              onPressed: () => podcastsModelOf(context).showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<PodcastsModel, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return AppIconButton(
              width: ComponentSize.normal.r,
              height: ComponentSize.normal.r,
              assetColor: viewMode.isGridMode
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconGrid,
              padding: EdgeInsets.all(ComponentInset.smaller.r),
              onPressed: () => podcastsModelOf(context).showGridViewMode());
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<Podcast, PodcastsModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, podcast, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return PodcastListItem(
                  podcast: podcast, onPodcastTap: _onPodcastTapped);
            case ItemListViewMode.grid:
              return PodcastGridItem(
                  width: 0.5.sw,
                  podcast: podcast,
                  showCreatorThumbnail: true,
                  onPodcastTap: _onPodcastTapped);
          }
        });
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      _buildSelectedFilterRow(),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<PodcastsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).podcasts,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).podcastsSearchHint,
          onQueryChanged: podcastsModelOf(context).updateSearchQuery,
          onQueryCleared: podcastsModelOf(context).clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<PodcastsModel, bool>(
        selector: (_, model) => model.isFilterApplied,
        builder: (_, areFiltersApplied, __) {
          return FilterIconSuffix(
            isSelected: areFiltersApplied,
            onPressed: _onFilterButtonTapped,
          );
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<PodcastsModel, List<PodcastCategory>?>(
        selector: (_, model) => model.selectedCategories,
        builder: (_, selectedCategories, __) {
          if (selectedCategories == null || selectedCategories.isEmpty) {
            return Container();
          }

          return PodcastsFilterLayout(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              categories: selectedCategories,
              onRemoveTap: (category) {
                podcastsModelOf(context).removeSelectedCategory(category);
              });
        });
  }

  PodcastsModel podcastsModelOf(BuildContext context) {
    return context.read<PodcastsModel>();
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final args = podcastsModelOf(context).createPodcastCategoryPickerArgs();

    final updatedArgs =
        await PodcastCategoryPickerBottomSheet.show(context, args);

    if (!mounted) return;
    if (updatedArgs != null) {
      podcastsModelOf(context)
          .setSelectedCategories(updatedArgs.selectedCategories);
    }
  }

  void _onPodcastTapped(Podcast podcast) {
    hideKeyboard(context);

    final args = PodcastDetailArgs(
      id: podcast.id,
      thumbnail: podcast.thumbnail,
      title: podcast.title,
    );
    DashboardNavigation.pushNamed(context, Routes.podcast, arguments: args);
  }
}
