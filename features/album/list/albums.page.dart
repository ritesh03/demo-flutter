import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart' as search;
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/album/detail/album.args.dart';
import 'package:kwotmusic/features/album/widget/album_grid_item.widget.dart';
import 'package:kwotmusic/features/album/widget/album_list_item.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/music/genre/selection/music_genre_selection.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'albums_applied_filters_list.widget.dart';
import 'albums.model.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({Key? key}) : super(key: key);

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends PageState<AlbumsPage> {
  //=
  AlbumsModel get _albumsModel => context.read<AlbumsModel>();

  @override
  void initState() {
    super.initState();
    _albumsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<AlbumsModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount = _albumsModel.viewColumnCount;
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
    return Selector<AlbumsModel, ItemListViewMode>(
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
              onPressed: () => _albumsModel.showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<AlbumsModel, ItemListViewMode>(
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
              onPressed: () => _albumsModel.showGridViewMode());
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<Album, AlbumsModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, album, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return AlbumListItem(album: album, onTap: _onAlbumTapped);
            case ItemListViewMode.grid:
              return AlbumGridItem(
                  width: 0.5.sw, album: album, onTap: _onAlbumTapped);
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
        child: Selector<AlbumsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).albums,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: search.SearchBar(
          hintText: LocaleResources.of(context).albumsSearchHint,
          onQueryChanged: _albumsModel.updateSearchQuery,
          onQueryCleared: _albumsModel.clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<AlbumsModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return search.FilterIconSuffix(
              isSelected: filtered, onPressed: _onFilterButtonTapped);
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<AlbumsModel, List<MusicGenre>?>(
        selector: (_, model) => model.selectedGenres,
        builder: (_, selectedGenres, __) {
          if (selectedGenres == null || selectedGenres.isEmpty) {
            return Container();
          }

          return AlbumsAppliedFiltersWidget(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              genres: selectedGenres,
              onRemoveTap: _albumsModel.removeSelectedGenre);
        });
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final selectedGenres = await MusicGenreSelectionBottomSheet.show(
        context, _albumsModel.selectedGenres);

    if (!mounted) return;
    if (selectedGenres != null) {
      _albumsModel.setSelectedGenres(selectedGenres);
    }
  }

  void _onAlbumTapped(Album album) {
    hideKeyboard(context);

    final thumbnail = album.images.isEmpty ? null : album.images.first;
    final args =
        AlbumArgs(id: album.id, thumbnail: thumbnail, title: album.title);
    DashboardNavigation.pushNamed(context, Routes.album, arguments: args);
  }
}
