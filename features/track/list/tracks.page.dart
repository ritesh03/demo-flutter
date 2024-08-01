import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
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
import 'package:kwotmusic/features/music/genre/selection/music_genre_selection.bottomsheet.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/track/widget/track_grid_item.widget.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'tracks.model.dart';
import 'tracks_applied_filters_list.widget.dart';

class TracksPage extends StatefulWidget {
  const TracksPage({Key? key}) : super(key: key);

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends PageState<TracksPage> {
  //=
  TracksModel get _tracksModel => context.read<TracksModel>();

  @override
  void initState() {
    super.initState();
    _tracksModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<TracksModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount = _tracksModel.viewColumnCount;
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
    return Selector<TracksModel, ItemListViewMode>(
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
              onPressed: () => _tracksModel.showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<TracksModel, ItemListViewMode>(
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
              onPressed: () => _tracksModel.showGridViewMode());
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<Track, TracksModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, track, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return TrackListItem(track: track, onTap: _onTrackTapped);
            case ItemListViewMode.grid:
              return TrackGridItem(
                  width: 0.5.sw,
                  track: track,
                  showCreatorThumbnail: true,
                  onTap: _onTrackTapped);
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
        child: Selector<TracksModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).songs,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          hintText: LocaleResources.of(context).songsSearchHint,
          onQueryChanged: _tracksModel.updateSearchQuery,
          onQueryCleared: _tracksModel.clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<TracksModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return FilterIconSuffix(
              isSelected: filtered, onPressed: _onFilterButtonTapped);
        });
  }

  Widget _buildSelectedFilterRow() {
    return Selector<TracksModel, List<MusicGenre>?>(
        selector: (_, model) => model.selectedGenres,
        builder: (_, selectedGenres, __) {
          if (selectedGenres == null || selectedGenres.isEmpty) {
            return Container();
          }

          return TracksAppliedFiltersWidget(
              margin: EdgeInsets.only(top: ComponentInset.normal.h),
              genres: selectedGenres,
              onRemoveTap: _tracksModel.removeSelectedGenre);
        });
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final selectedGenres = await MusicGenreSelectionBottomSheet.show(
        context, _tracksModel.selectedGenres);

    if (!mounted) return;
    if (selectedGenres != null) {
      _tracksModel.setSelectedGenres(selectedGenres);
    }
  }

  bool _onTrackTapped(Track track) {
    hideKeyboard(context);

    final request = _tracksModel.createPlayTrackRequest(track);
    locator<AudioPlaybackActionsModel>().playTrackUsingRequest(request);
    return true;
  }
}
