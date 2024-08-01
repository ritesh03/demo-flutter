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
import 'package:kwotmusic/features/podcast/list/podcasts.model.dart';
import 'package:kwotmusic/features/podcastcategory/list/podcast_categories.model.dart';
import 'package:kwotmusic/features/podcastcategory/widget/podcast_category_grid_item.widget.dart';
import 'package:kwotmusic/features/podcastcategory/widget/podcast_category_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

class PodcastCategoriesPage extends StatefulWidget {
  const PodcastCategoriesPage({Key? key}) : super(key: key);

  @override
  State<PodcastCategoriesPage> createState() => _PodcastCategoriesPageState();
}

class _PodcastCategoriesPageState extends PageState<PodcastCategoriesPage> {
  //=

  @override
  void initState() {
    super.initState();
    podcastCategoriesModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<PodcastCategoriesModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount =
                      podcastCategoriesModelOf(context).viewColumnCount;
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
    return Selector<PodcastCategoriesModel, ItemListViewMode>(
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
              onPressed: () =>
                  podcastCategoriesModelOf(context).showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<PodcastCategoriesModel, ItemListViewMode>(
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
              onPressed: () =>
                  podcastCategoriesModelOf(context).showGridViewMode());
        });
  }

  /*
   * HEADER
   */

  Widget _buildHeader() {
    return Container(
        padding: EdgeInsets.only(
            top: ComponentInset.small.r,
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.normal.r),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitle(),
          _buildSearchBar(),
        ]));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
        child: Selector<PodcastCategoriesModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, pageTitle, __) {
              return SimpleMarquee(
                  text: pageTitle ??
                      LocaleResources.of(context).podcastCategoriesPageTitle,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return SearchBar(
        hintText: LocaleResources.of(context).podcastCategoriesSearchHint,
        onQueryChanged: podcastCategoriesModelOf(context).updateSearchQuery,
        onQueryCleared: podcastCategoriesModelOf(context).clearSearchQuery);
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<PodcastCategory, PodcastCategoriesModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, podcastCategory, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return PodcastCategoryListItem(
                  category: podcastCategory, onTap: _onPodcastCategoryTap);
            case ItemListViewMode.grid:
              return PodcastCategoryGridItem(
                  category: podcastCategory,
                  width: 0.5.sw,
                  index: index,
                  onTap: _onPodcastCategoryTap);
          }
        });
  }

  PodcastCategoriesModel podcastCategoriesModelOf(BuildContext context) {
    return context.read<PodcastCategoriesModel>();
  }

  void _onPodcastCategoryTap(PodcastCategory category) {
    DashboardNavigation.pushNamed(
      context,
      Routes.podcasts,
      arguments: PodcastListArgs(selectedCategory: category),
    );
  }
}
