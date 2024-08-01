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
import 'package:kwotmusic/features/podcastcategory/picker/podcast_category_picker.bottomsheet.dart';
import 'package:kwotmusic/features/podcastepisode/detail/podcast_episode_detail.model.dart';
import 'package:kwotmusic/features/podcastepisode/filter/podcast_episodes_filter_layout.widget.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_grid_item.widget.dart';
import 'package:kwotmusic/features/podcastepisode/widget/podcast_episode_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'podcast_episodes.model.dart';

class PodcastEpisodesPage extends StatefulWidget {
  const PodcastEpisodesPage({Key? key}) : super(key: key);

  @override
  State<PodcastEpisodesPage> createState() => _PodcastEpisodesPageState();
}

class _PodcastEpisodesPageState extends PageState<PodcastEpisodesPage> {
  //=

  @override
  void initState() {
    super.initState();
    episodesModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
              child: _buildAppBar(),
              preferredSize: Size.fromHeight(ComponentSize.large.h),
            ),
            body: Selector<PodcastEpisodesModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final viewColumnCount =
                      episodesModelOf(context).viewColumnCount;
                  return _buildItemList(viewMode, viewColumnCount);
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
    return Selector<PodcastEpisodesModel, ItemListViewMode>(
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
              onPressed: () => episodesModelOf(context).showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<PodcastEpisodesModel, ItemListViewMode>(
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
              onPressed: () => episodesModelOf(context).showGridViewMode());
        });
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
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<PodcastEpisodesModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, pageTitle, __) {
              return SimpleMarquee(
                  text: pageTitle ??
                      LocaleResources.of(context).podcastEpisodesPageTitle,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).podcastEpisodesSearchHint,
          onQueryChanged: episodesModelOf(context).updateSearchQuery,
          onQueryCleared: episodesModelOf(context).clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<PodcastEpisodesModel, bool>(
        selector: (_, model) => model.isFilterApplied,
        builder: (_, areFiltersApplied, __) {
          return FilterIconSuffix(
            isSelected: areFiltersApplied,
            onPressed: _onFilterButtonTapped,
          );
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<PodcastEpisodesModel, List<PodcastCategory>?>(
        selector: (_, model) => model.selectedCategories,
        builder: (_, selectedCategories, __) {
          if (selectedCategories == null || selectedCategories.isEmpty) {
            return Container();
          }

          return PodcastEpisodesFilterLayout(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              categories: selectedCategories,
              onRemoveTap: (category) {
                episodesModelOf(context).removeSelectedCategory(category);
              });
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<PodcastEpisode, PodcastEpisodesModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, podcastEpisode, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return PodcastEpisodeListItem(
                podcastEpisode: podcastEpisode,
                onPodcastEpisodeTap: _onPodcastEpisodeTapped,
              );
            case ItemListViewMode.grid:
              return PodcastEpisodeGridItem(
                podcastEpisode: podcastEpisode,
                onPodcastEpisodeTap: _onPodcastEpisodeTapped,
                width: 0.5.sw,
              );
          }
        });
  }

  PodcastEpisodesModel episodesModelOf(BuildContext context) {
    return context.read<PodcastEpisodesModel>();
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final args = episodesModelOf(context).createPodcastCategoryPickerArgs();

    final updatedArgs =
        await PodcastCategoryPickerBottomSheet.show(context, args);
    if (updatedArgs != null) {
      episodesModelOf(context)
          .setSelectedCategories(updatedArgs.selectedCategories);
    }
  }

  void _onPodcastEpisodeTapped(PodcastEpisode episode) {
    final args = PodcastEpisodeDetailArgs.object(episode: episode);
    DashboardNavigation.pushNamed(context, Routes.podcastEpisode,
        arguments: args);
  }
}
