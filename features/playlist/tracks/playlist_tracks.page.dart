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
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/track/options/track_options.bottomsheet.dart';
import 'package:kwotmusic/features/track/options/track_options.model.dart';
import 'package:kwotmusic/features/track/widget/track_grid_item.widget.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'playlist_tracks.model.dart';
import 'sort/playlist_tracks_sort_options.bottomsheet.dart';

class PlaylistTracksPage extends StatefulWidget {
  const PlaylistTracksPage({Key? key}) : super(key: key);

  @override
  State<PlaylistTracksPage> createState() => _PlaylistTracksPageState();
}

class _PlaylistTracksPageState extends PageState<PlaylistTracksPage> {
  //=
  PlaylistTracksModel get _playlistTracksModel =>
      context.read<PlaylistTracksModel>();

  @override
  void initState() {
    super.initState();
    _playlistTracksModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<PlaylistTracksModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final columnCount = _playlistTracksModel.viewColumnCount;
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
    return Selector<PlaylistTracksModel, ItemListViewMode>(
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
              onPressed: () => _playlistTracksModel.showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<PlaylistTracksModel, ItemListViewMode>(
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
              onPressed: () => _playlistTracksModel.showGridViewMode());
        });
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<Track, PlaylistTracksModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, track, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return TrackListItem(
                track: track,
                onTap: _onTrackTap,
                onOptionsButtonTap: _onTrackOptionsTap,
              );
            case ItemListViewMode.grid:
              return TrackGridItem(
                  width: 0.5.sw,
                  track: track,
                  showCreatorThumbnail: true,
                  onTap: _onTrackTap);
          }
        });
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<PlaylistTracksModel, String>(
            selector: (_, model) => model.playlist.name,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: SearchBar(
          controller: _playlistTracksModel.searchQueryController,
          hintText: LocaleResources.of(context).playlistTracksSearchHint,
          onQueryChanged: _playlistTracksModel.updateSearchQuery,
          onQueryCleared: _playlistTracksModel.clearSearchQuery,
          suffixes: [_buildFilterIconWidget()]),
    );
  }

  Widget _buildFilterIconWidget() {
    return Selector<PlaylistTracksModel, bool>(
        selector: (_, model) => model.hasCustomSort,
        builder: (_, filtered, __) {
          return FilterIconSuffix(
            isSelected: filtered,
            onPressed: _onFilterButtonTapped,
          );
        });
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final selectedSortBy = await PlaylistTracksSortOptionsBottomSheet.show(
        context,
        sortBy: _playlistTracksModel.selectedSortBy);

    if (!mounted) return;
    if (selectedSortBy != null) {
      _playlistTracksModel.setSelectedSortBy(selectedSortBy);
    }
  }

  bool _onTrackTap(Track track) {
    hideKeyboard(context);

    final request = _playlistTracksModel.createPlayTrackRequest(track);
    locator<AudioPlaybackActionsModel>().playTrackUsingRequest(request);
    return true;
  }

  bool _onTrackOptionsTap(Track track) {
    hideKeyboard(context);

    TrackOptionsBottomSheet.show(
      context,
      args: TrackOptionsArgs(
          track: track, playlist: _playlistTracksModel.playlist),
    );
    return true;
  }
}
