import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_grid_item.widget.dart';
import 'package:kwotmusic/features/artist/widget/artist_list_item.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/music/genre/selection/music_genre_selection.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'artists.model.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({Key? key}) : super(key: key);

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends PageState<ArtistsPage> {
  //=
  ArtistsModel get _artistsModel => context.read<ArtistsModel>();

  @override
  void initState() {
    super.initState();
    _artistsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<ArtistsModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount = _artistsModel.viewColumnCount;
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
    return Selector<ArtistsModel, ItemListViewMode>(
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
              onPressed: () => _artistsModel.showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<ArtistsModel, ItemListViewMode>(
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
              onPressed: () => _artistsModel.showGridViewMode());
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<Artist, ArtistsModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, artist, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return ArtistListItem(
                artist: artist,
                onTap: () => _onArtistTapped(artist),
                onFollowTap: () => _onFollowArtistTapped(artist),
              );
            case ItemListViewMode.grid:
              return ArtistGridItem(
                  artist: artist, onTap: _onArtistTapped, width: 0.5.sw);
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
        child: Selector<ArtistsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).artists,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).search,
          onQueryChanged: _artistsModel.updateSearchQuery,
          onQueryCleared: _artistsModel.clearSearchQuery,
          suffixes: [
            if (_artistsModel.canShowGenreFilter) _buildFilterIconWidget(),
          ]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<ArtistsModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return FilterIconSuffix(
              isSelected: filtered, onPressed: _onFilterButtonTapped);
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<ArtistsModel, List<MusicGenre>?>(
        selector: (_, model) => model.selectedGenres,
        builder: (_, selectedGenres, __) {
          if (selectedGenres == null || selectedGenres.isEmpty) {
            return Container();
          }

          return _ArtistsAppliedFiltersWidget(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              genres: selectedGenres,
              onRemoveTap: _artistsModel.removeSelectedGenre);
        });
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final selectedGenres = await MusicGenreSelectionBottomSheet.show(
        context, _artistsModel.selectedGenres);

    if (!mounted) return;
    if (selectedGenres != null) {
      _artistsModel.setSelectedGenres(selectedGenres);
    }
  }

  void _onArtistTapped(Artist artist) {
    hideKeyboard(context);

    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onFollowArtistTapped(Artist artist) async {
    hideKeyboard(context);

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<ArtistActionsModel>().setIsFollowed(
      id: artist.id,
      shouldFollow: !artist.isFollowed,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }
}

class _ArtistsAppliedFiltersWidget extends StatelessWidget {
  const _ArtistsAppliedFiltersWidget({
    Key? key,
    required this.genres,
    required this.onRemoveTap,
    this.margin,
  }) : super(key: key);

  final List<MusicGenre> genres;
  final Function(MusicGenre) onRemoveTap;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FilterChipLayout(
      items: genres.map(_genreToChipItem).toList(),
      margin: margin,
    );
  }

  FilterChipItem _genreToChipItem(MusicGenre genre) {
    return FilterChipItem(
      text: genre.title,
      action: () => onRemoveTap(genre),
    );
  }
}
