import 'package:flutter/material.dart'  hide SearchBar;
import 'package:get/get.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/album/detail/album.args.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/downloads/downloads_actions.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/addtoplaylist/add_to_playlist.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/features/playlist/tracks/remove/remove_playlist_track_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_enforcement.dart';
import 'package:kwotmusic/features/track/artists/track_artists.page.dart';
import 'package:kwotmusic/features/track/download/track_download_option.widget.dart';
import 'package:kwotmusic/features/track/track_actions.model.dart';
import 'package:kwotmusic/features/track/widget/track_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/error_code_messages.dart';
import 'package:kwotmusic/util/ext_build_context_mounted.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'track_options.model.dart';

class TrackOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required TrackOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) {
        return ChangeNotifierProvider(
            create: (_) => TrackOptionsModel(args: args),
            child: const TrackOptionsBottomSheet());
      },
    );
  }

  const TrackOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<TrackOptionsBottomSheet> createState() =>
      _TrackOptionsBottomSheetState();
}

class _TrackOptionsBottomSheetState extends State<TrackOptionsBottomSheet> {
  //=

  TrackOptionsModel get _trackOptionsModel => context.read<TrackOptionsModel>();

  Track get _track => _trackOptionsModel.track;

  @override
  Widget build(BuildContext context) {
    final tileMargin = EdgeInsets.only(top: ComponentInset.small.h);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.r),
          _buildHeader(),
          SizedBox(height: ComponentInset.normal.r),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          Flexible(
            child: SingleChildScrollView(
              child: Column(children: [
                // LIKE
                _buildLikeOption(tileMargin),

                // ADD TO PLAYLIST
                BottomSheetTile(
                  iconPath: Assets.iconMusicList,
                  margin: tileMargin,
                  text: LocaleResources.of(context).addToPlaylist,
                  onTap: _onAddToPlaylistButtonTapped,
                ),

                // ADD TO QUEUE
                _AddToQueueOption(
                  margin: tileMargin,
                  onTap: _onAddToQueueButtonTapped,
                ),

                // DOWNLOAD
                _DownloadOption(
                  margin: tileMargin,
                  onTap: _onDownloadButtonTapped,
                ),

                // SHARE
                BottomSheetTile(
                  iconPath: Assets.iconShare,
                  margin: tileMargin,
                  text: LocaleResources.of(context).share,
                  onTap: _onShareButtonTapped,
                ),

                // VIEW ALBUM
                _ViewAlbumOption(
                  margin: tileMargin,
                  onTap: _onViewAlbumButtonTapped,
                ),

                // VIEW ARTISTS
                _buildArtistsOption(tileMargin),

                // REPORT
                BottomSheetTile(
                  iconPath: Assets.iconReport,
                  margin: tileMargin,
                  text: LocaleResources.of(context).report,
                  onTap: _onReportTrackButtonTapped,
                ),

                // REMOVE FROM PLAYLIST
                _RemoveTrackFromPlaylistOption(
                  margin: tileMargin,
                  onTap: _onRemoveSongFromPlaylistTap,
                ),

                // DOWNLOAD STATUS
                TrackDownloadOptionWidget(margin: tileMargin, track: _track),

                // REMOVE FROM PLAYING QUEUE
                _RemoveFromPlayingQueueOption(
                  margin: tileMargin,
                  onTap: _onRemoveSongFromPlayingQueueTap,
                ),
                SizedBox(height: ComponentInset.normal.r),
              ]),
            ),
          ),
        ]));
  }

  Widget _buildHeader() {
    return Selector<TrackOptionsModel, Track>(
      selector: (_, model) => model.track,
      builder: (_, track, __) => TrackCompactPreview(track: track),
    );
  }

  Widget _buildLikeOption(EdgeInsets tileMargin) {
    return Selector<TrackOptionsModel, bool>(
        selector: (_, model) => model.liked,
        builder: (_, liked, __) {
          return BottomSheetTile(
              iconPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              margin: tileMargin,
              text: liked
                  ? LocaleResources.of(context).unlike
                  : LocaleResources.of(context).like,
              onTap: () => _onLikeButtonTapped(context));
        });
  }

  Widget _buildArtistsOption(EdgeInsets tileMargin) {
    return Selector<TrackOptionsModel, List<Artist>>(
        selector: (_, model) => model.artists,
        builder: (_, artists, __) {
          if (artists.isEmpty) return Container();

          if (artists.length == 1) {
            return BottomSheetTile(
                iconPath: Assets.iconProfile,
                margin: tileMargin,
                text: LocaleResources.of(context).viewArtist,
                onTap: () => _onViewArtistButtonTapped(artists.first));
          }

          return BottomSheetTile(
              iconPath: Assets.iconProfile,
              margin: tileMargin,
              text: LocaleResources.of(context).viewArtists,
              onTap: _onViewArtistsButtonTapped);
        });
  }

  void _onLikeButtonTapped(BuildContext context) async {
    showBlockingProgressDialog(context);

    final track = _trackOptionsModel.track;
    final result = await locator<TrackActionsModel>().toggleLike(track);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onAddToPlaylistButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final track = _trackOptionsModel.track;
    AddToPlaylistBottomSheet.forTrack(context, track);
  }

  void _onAddToQueueButtonTapped() async {
    showBlockingProgressDialog(context);

    final track = _trackOptionsModel.track;
    final result =
        await locator<AudioPlaybackActionsModel>().addTrackToQueue(track);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (result.isSuccess()) {
      RootNavigation.popUntilRoot(context);

      showDefaultNotificationBar(
        NotificationBarInfo.success(
          message: result.message,
          actionText: LocaleResources.of(context).viewPlayingQueue,
          actionCallback: (context) => PlayingQueueBottomSheet.show(context),
        ),
      );
    } else if (result.errorCode() != null) {
      final errorMessage =
          getErrorMessageFromErrorCode(context, result.errorCode()!);
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: errorMessage));
    } else {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onDownloadButtonTapped() async {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "Offline Download", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowMessage,
    );
    if (!fulfilled) {
      RootNavigation.popUntilRoot(context);
      return;
    }

    final downloadStatus = _trackOptionsModel.downloadStatusNotifier.value;
    if (downloadStatus != null &&
        downloadStatus != TrackDownloadStatus.unknown &&
        downloadStatus != TrackDownloadStatus.cancelled) return;

    final track = _trackOptionsModel.track;

    showBlockingProgressDialog(context);
    final Result result;
    if (downloadStatus == TrackDownloadStatus.cancelled) {
      result =
          await locator<DownloadActionsModel>().retryTrackDownload(track.id);
    } else {
      result = await locator<DownloadActionsModel>().startTrackDownload(track);
    }

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onShareButtonTapped() async {
    final track = _trackOptionsModel.track;
    final shareableLink = track.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onViewAlbumButtonTapped() async {
    final track = _trackOptionsModel.track;
    final albumInfo = track.albumInfo;
    if (albumInfo == null) return;

    RootNavigation.popUntilRoot(context);

    final args = AlbumArgs(
      id: albumInfo.id,
      title: albumInfo.title,
      thumbnail: track.images.isEmpty ? null : track.images.first,
    );
    DashboardNavigation.pushNamed(context, Routes.album, arguments: args);
  }

  void _onViewArtistButtonTapped(Artist artist) {
    RootNavigation.popUntilRoot(context);

    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onViewArtistsButtonTapped() {
    RootNavigation.popUntilRoot(context);

    DashboardNavigation.pushNamed(
      context,
      Routes.trackArtists,
      arguments: TrackArtistsArgs(track: _trackOptionsModel.track),
    );
  }

  void _onReportTrackButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final track = _trackOptionsModel.track;
    final args = ReportContentArgs(content: ReportableContent.fromTrack(track));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }

  void _onRemoveSongFromPlaylistTap() async {
    bool? shouldRemove =
        await RemovePlaylistTrackConfirmationBottomSheet.show(context);
    if (!mounted) return;
    if (shouldRemove == null || !shouldRemove) {
      return;
    }

    final track = context.read<TrackOptionsModel>().track;
    final playlistInfo = track.playlistInfo;
    if (playlistInfo == null) {
      return;
    }

    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().removeTrack(
      playlistId: playlistInfo.playlistId,
      playlistItemId: playlistInfo.playlistItemId,
      trackId: track.id,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(NotificationBarInfo.success(
      message: result.message,
      actionText: LocaleResources.of(context).undo,
      actionCallback: (context) {
        _onUndoRemoveTrackFromPlaylistTap(
          playlistId: playlistInfo.playlistId,
          track: track,
        );
      },
    ));
    RootNavigation.popUntilRoot(context);
  }

  void _onUndoRemoveTrackFromPlaylistTap({
    required String playlistId,
    required Track track,
  }) async {
    final context = Get.overlayContext!;
    if (!context.mounted) return;
    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().undoRemoveTrack(
      playlistId: playlistId,
      track: track,
    );

    if (!context.mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }

  void _onRemoveSongFromPlayingQueueTap() async {
    final playbackItem = context.read<TrackOptionsModel>().args.playbackItem;
    if (playbackItem == null) return;

    showBlockingProgressDialog(context);
    locator<AudioPlaybackActionsModel>().removePlaybackItem(playbackItem).then(
      (result) {
        if (!mounted) return;
        hideBlockingProgressDialog(context);

        if (!result.isSuccess()) {
          showDefaultNotificationBar(
              NotificationBarInfo.error(message: result.error()));
          return;
        }

        RootNavigation.pop(context);
      },
    );
  }
}

class _AddToQueueOption extends StatelessWidget {
  const _AddToQueueOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<TrackOptionsModel, PlaybackItem?>(
        selector: (_, model) => model.args.playbackItem,
        builder: (_, playbackItem, __) {
          if (playbackItem != null) return const SizedBox.shrink();
          return BottomSheetTile(
              iconPath: Assets.iconQueue,
              margin: margin,
              text: LocaleResources.of(context).addToQueue,
              onTap: onTap);
        });
  }
}

class _DownloadOption extends StatelessWidget {
  const _DownloadOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrackDownloadStatus?>(
      valueListenable: context.read<TrackOptionsModel>().downloadStatusNotifier,
      builder: (_, downloadStatus, child) {
        if (downloadStatus == null ||
            downloadStatus == TrackDownloadStatus.unknown ||
            downloadStatus == TrackDownloadStatus.cancelled) return child!;
        return const SizedBox.shrink();
      },
      child: BottomSheetTile(
          iconPath: Assets.iconDownload,
          margin: margin,
          text: LocaleResources.of(context).download,
          onTap: onTap),
    );
  }
}

class _RemoveFromPlayingQueueOption extends StatelessWidget {
  const _RemoveFromPlayingQueueOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<TrackOptionsModel, PlaybackItem?>(
        selector: (_, model) => model.args.playbackItem,
        builder: (_, playbackItem, __) {
          if (playbackItem == null) return const SizedBox.shrink();
          return BottomSheetDiscouragedOption(
              iconPath: Assets.iconDelete,
              text: LocaleResources.of(context).playingQueueRemoveItem,
              margin: margin,
              onTap: onTap);
        });
  }
}

class _RemoveTrackFromPlaylistOption extends StatelessWidget {
  const _RemoveTrackFromPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<TrackOptionsModel, bool>(
        selector: (_, model) => model.isInPlaylist,
        builder: (_, isInPlaylist, __) {
          if (!isInPlaylist) return const SizedBox.shrink();

          return BottomSheetDiscouragedOption(
              iconPath: Assets.iconDelete,
              text: LocaleResources.of(context).playlistRemoveSong,
              margin: margin,
              onTap: onTap);
        });
  }
}

class _ViewAlbumOption extends StatelessWidget {
  const _ViewAlbumOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<TrackOptionsModel, bool>(
        selector: (_, model) => model.canShowViewAlbumOption,
        builder: (_, canShowViewAlbumOption, __) {
          if (!canShowViewAlbumOption) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconAlbum,
              margin: margin,
              text: LocaleResources.of(context).viewAlbum,
              onTap: onTap);
        });
  }
}
