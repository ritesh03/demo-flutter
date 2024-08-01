import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/chip/chip_selection_layout.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'playlist_add_tracks.model.dart';
import 'playlist_add_tracks.page.actions.dart';
import 'trackexists/track_exists_in_playlist.bottomsheet.dart';

class PlaylistAddTracksPage extends StatefulWidget {
  const PlaylistAddTracksPage({Key? key}) : super(key: key);

  @override
  State<PlaylistAddTracksPage> createState() => _PlaylistAddTracksPageState();
}

class _PlaylistAddTracksPageState extends PageState<PlaylistAddTracksPage>
    implements PlaylistAddTracksPageActionCallback {
  //=
  late ScrollController _scrollController;
  late TextEditingController _searchInputController;
  late String _targetPlaylistId;

  PlaylistAddTracksModel get _tracksModel =>
      context.read<PlaylistAddTracksModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    final tracksModel = _tracksModel;
    tracksModel.init();
    _searchInputController = tracksModel.searchInputController;
    _targetPlaylistId = tracksModel.playlistId;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _FloatingPageTitleBar(
          onTitleTap: _scrollController.animateToTop,
          onDoneTap: onDoneTap,
          child: _ItemList(
            playlistId: _targetPlaylistId,
            scrollController: _scrollController,
            searchInputController: _searchInputController,
            callback: this,
          ),
        ),
      ),
    );
  }

  @override
  void onBackTap() {
    DashboardNavigation.pop(context);
  }

  @override
  void onDoneTap() {
    final args = _tracksModel.args;
    final playlist = args.playlist;

    if (args.isOnPlaylistPage) {
      Navigator.pop(context);
      return;
    }

    DashboardNavigation.pushReplacementNamed(
      context,
      Routes.playlist,
      arguments: PlaylistArgs(
        id: playlist.id,
        title: playlist.name,
        thumbnail: playlist.images.isEmpty ? null : playlist.images.first,
      ),
    );
  }

  @override
  void onAddTrackTap(
    Track track, {
    bool allowDuplicate = false,
  }) async {
    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().addTrack(
      playlistId: _targetPlaylistId,
      track: track,
      allowDuplicate: allowDuplicate,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      if (result.errorCode() ==
          ErrorCodes.playlistUpdateFailedWhenTrackExists) {
        _handleOnAddDuplicateTrackAttempted(track);
        return;
      }

      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  @override
  void onRemoveTrackTap(Track track) async {
    final playlistInfo = track.playlistInfo;
    if (playlistInfo == null || playlistInfo.playlistId != _targetPlaylistId) {
      return;
    }

    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().removeTrack(
      playlistId: _targetPlaylistId,
      playlistItemId: playlistInfo.playlistItemId,
      trackId: track.id,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _handleOnAddDuplicateTrackAttempted(Track track) async {
    final shouldAddDuplicateTrack =
        await TrackExistsInPlaylistBottomSheet.show(context);

    if (!mounted) return;
    if (shouldAddDuplicateTrack != null && shouldAddDuplicateTrack) {
      onAddTrackTap(track, allowDuplicate: true);
    }
  }
}

class _FloatingPageTitleBar extends StatelessWidget {
  const _FloatingPageTitleBar({
    Key? key,
    required this.onTitleTap,
    required this.onDoneTap,
    required this.child,
  }) : super(key: key);

  final VoidCallback onTitleTap;
  final VoidCallback onDoneTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTitleBarWrapper(
        barHeight: ComponentSize.large.r,
        title: PageTitleBarText(
            text: LocaleResources.of(context).playlistAddSongsPageTitle,
            color: DynamicTheme.get(context).white(),
            onTap: onTitleTap),
        centerTitle: false,
        actions: [
          _DoneButton(onTap: onDoneTap),
          SizedBox(width: ComponentInset.normal.w),
        ],
        child: child);
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.playlistId,
    required this.scrollController,
    required this.searchInputController,
    required this.callback,
  }) : super(key: key);

  final String playlistId;
  final ScrollController scrollController;
  final TextEditingController searchInputController;
  final PlaylistAddTracksPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<Track, PlaylistAddTracksModel>(
        controller: scrollController,
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        headerSlivers: [
          SliverToBoxAdapter(
            child: _ItemListHeader(
              searchInputController: searchInputController,
              onBackTap: callback.onBackTap,
              onDoneTap: callback.onDoneTap,
            ),
          ),
        ],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, track, index) {
          final isInPlaylist = track.isInPlaylist(playlistId);
          return TrackListItem(
              track: track,
              trailing: isInPlaylist
                  ? _RemoveTrackFromPlaylistButton(
                      size: ComponentSize.large.r,
                      onTap: () => callback.onRemoveTrackTap(track),
                    )
                  : _AddTrackToPlaylistButton(
                      size: ComponentSize.large.r,
                      onTap: () => callback.onAddTrackTap(track),
                    ));
        });
  }
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader({
    Key? key,
    required this.searchInputController,
    required this.onBackTap,
    required this.onDoneTap,
  }) : super(key: key);

  final TextEditingController searchInputController;
  final VoidCallback onBackTap;
  final VoidCallback onDoneTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: ComponentSize.large.h,
        child: Row(children: [
          AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconArrowLeft,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: onBackTap),
          const Spacer(),
          _DoneButton(onTap: onDoneTap),
          SizedBox(width: ComponentInset.normal.w)
        ]),
      ),
      SizedBox(height: ComponentInset.small.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Text(
          LocaleResources.of(context).playlistAddSongsPageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading2
              .copyWith(color: DynamicTheme.get(context).white()),
        ),
      ),
      SizedBox(height: ComponentInset.normal.h),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: SearchBar(
              controller: searchInputController,
              hintText: LocaleResources.of(context).songsSearchHint,
              onQueryChanged: modelOf(context).updateSearchQuery,
              onQueryCleared: modelOf(context).clearSearchQuery)),
      SizedBox(height: ComponentInset.normal.h),
      const _TracksSourceTypeSelection(),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  PlaylistAddTracksModel modelOf(BuildContext context) {
    return context.read<PlaylistAddTracksModel>();
  }
}

class _TracksSourceTypeSelection extends StatelessWidget {
  const _TracksSourceTypeSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistAddTracksModel, PlaylistTrackSource?>(
        selector: (_, model) => model.selectedTrackSource,
        builder: (_, selectedTrackSource, __) {
          return ChipSelectionLayoutWidget<PlaylistTrackSource>(
              height: ComponentSize.normal.h,
              items: PlaylistTrackSource.values,
              itemTitle: (trackSource) {
                switch (trackSource) {
                  case PlaylistTrackSource.suggested:
                    return LocaleResources.of(context).suggested;
                  case PlaylistTrackSource.recentlyPlayed:
                    return LocaleResources.of(context).recentlyPlayed;
                  case PlaylistTrackSource.liked:
                    return LocaleResources.of(context).likedSongs;
                }
              },
              itemInnerSpacing: ComponentInset.small.r,
              itemOuterSpacing: ComponentInset.normal.r,
              onItemSelect: (trackSource) {
                hideKeyboard(context);
                context
                    .read<PlaylistAddTracksModel>()
                    .setSelectedTrackSource(trackSource);
              },
              selectedItem: selectedTrackSource);
        });
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        text: LocaleResources.of(context).done,
        type: ButtonType.text,
        height: ComponentSize.smaller.h,
        onPressed: onTap);
  }
}

class _AddTrackToPlaylistButton extends StatelessWidget {
  const _AddTrackToPlaylistButton({
    Key? key,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      width: size,
      height: size,
      padding: EdgeInsets.all(ComponentInset.small.r),
      assetPath: Assets.iconAddMedium,
      assetColor: DynamicTheme.get(context).white(),
      onPressed: onTap,
    );
  }
}

class _RemoveTrackFromPlaylistButton extends StatelessWidget {
  const _RemoveTrackFromPlaylistButton({
    Key? key,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      width: size,
      height: size,
      padding: EdgeInsets.all(ComponentInset.small.r),
      assetPath: Assets.iconCheckMedium,
      assetColor: DynamicTheme.get(context).secondary100(),
      onPressed: onTap,
    );
  }
}
