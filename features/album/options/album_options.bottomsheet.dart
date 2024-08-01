import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/album/album_actions.model.dart';
import 'package:kwotmusic/features/album/artists/album_artists.page.dart';
import 'package:kwotmusic/features/album/widget/album_compact_preview.widget.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/addtoplaylist/add_to_playlist.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/error_code_messages.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'album_options.model.dart';

class AlbumOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required AlbumOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) => ChangeNotifierProvider(
          create: (_) => AlbumOptionsModel(args: args),
          child: const AlbumOptionsBottomSheet()),
    );
  }

  const AlbumOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<AlbumOptionsBottomSheet> createState() =>
      _AlbumOptionsBottomSheetState();
}

class _AlbumOptionsBottomSheetState extends State<AlbumOptionsBottomSheet> {
  //=
  AlbumOptionsModel get _albumOptionsModel => context.read<AlbumOptionsModel>();

  AlbumActionsModel get _albumActionsModel => locator<AlbumActionsModel>();

  @override
  Widget build(BuildContext context) {
    final margin = EdgeInsets.only(top: ComponentInset.small.h);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          const _AlbumBottomSheetHeader(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          // TODO: Like All Songs
          _AlbumLikeOption(margin: margin, onTap: _onLikeButtonTapped),
          _AddAlbumToPlaylistOption(
            margin: margin,
            onTap: _onAddToPlaylistButtonTapped,
          ),
          BottomSheetTile(
              iconPath: Assets.iconQueue,
              margin: margin,
              text: LocaleResources.of(context).addToQueue,
              onTap: _onAddToQueueButtonTapped),
          // _DownloadAlbumOption(margin: margin, onTap: _onDownloadButtonTapped),
          _ShareAlbumOption(margin: margin, onTap: _onShareButtonTapped),
          _ViewArtistsOption(
            margin: margin,
            onTap: _onViewArtistTap,
            onViewAllTap: _onViewArtistsTap,
          ),
          _AlbumReportOption(margin: margin, onTap: _onReportAlbumButtonTapped),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  void _onLikeButtonTapped() async {
    final album = _albumOptionsModel.album;

    showBlockingProgressDialog(context);
    final result = await _albumActionsModel.toggleLike(album);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onAddToPlaylistButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final album = _albumOptionsModel.album;
    AddToPlaylistBottomSheet.forAlbum(context, album);
  }

  void _onAddToQueueButtonTapped() async {
    final album = _albumOptionsModel.album;

    showBlockingProgressDialog(context);
    final result =
        await locator<AudioPlaybackActionsModel>().addAlbumToQueue(album);

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

  void _onDownloadButtonTapped() {}

  void _onShareButtonTapped() async {
    final album = _albumOptionsModel.album;
    Share.share(album.shareableLink);
  }

  void _onViewArtistTap(Artist artist) {
    RootNavigation.popUntilRoot(context);

    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onViewArtistsTap() {
    RootNavigation.popUntilRoot(context);

    DashboardNavigation.pushNamed(context, Routes.albumArtists,
        arguments: AlbumArtistsArgs(album: _albumOptionsModel.album));
  }

  void _onReportAlbumButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final album = _albumOptionsModel.album;
    final args = ReportContentArgs(content: ReportableContent.fromAlbum(album));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}

class _AlbumBottomSheetHeader extends StatelessWidget {
  const _AlbumBottomSheetHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumOptionsModel, Album>(
      selector: (_, model) => model.album,
      builder: (_, album, __) => AlbumCompactPreview(album: album),
    );
  }
}

class _AlbumLikeOption extends StatelessWidget {
  const _AlbumLikeOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumOptionsModel, bool>(
        selector: (_, model) => model.liked,
        builder: (_, liked, __) {
          return BottomSheetTile(
              iconPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              margin: margin,
              text: liked
                  ? LocaleResources.of(context).unlike
                  : LocaleResources.of(context).like,
              onTap: onTap);
        });
  }
}

class _AddAlbumToPlaylistOption extends StatelessWidget {
  const _AddAlbumToPlaylistOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTile(
        iconPath: Assets.iconMusicList,
        margin: margin,
        text: LocaleResources.of(context).addToPlaylist,
        onTap: onTap);
  }
}

class _DownloadAlbumOption extends StatelessWidget {
  const _DownloadAlbumOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTile(
        iconPath: Assets.iconDownload,
        margin: margin,
        text: LocaleResources.of(context).download,
        onTap: onTap);
  }
}

class _ShareAlbumOption extends StatelessWidget {
  const _ShareAlbumOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTile(
        iconPath: Assets.iconShare,
        margin: margin,
        text: LocaleResources.of(context).share,
        onTap: onTap);
  }
}

class _ViewArtistsOption extends StatelessWidget {
  const _ViewArtistsOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
    required this.onViewAllTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final Function(Artist) onTap;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumOptionsModel, List<Artist>>(
        selector: (_, model) => model.album.artists,
        builder: (_, artists, __) {
          if (artists.isEmpty) return Container();

          if (artists.length == 1) {
            return BottomSheetTile(
                iconPath: Assets.iconProfile,
                margin: margin,
                text: LocaleResources.of(context).viewArtist,
                onTap: () => onTap(artists.first));
          }

          return BottomSheetTile(
              iconPath: Assets.iconProfile,
              margin: margin,
              text: LocaleResources.of(context).viewArtists,
              onTap: onViewAllTap);
        });
  }
}

class _AlbumReportOption extends StatelessWidget {
  const _AlbumReportOption({
    Key? key,
    this.margin = EdgeInsets.zero,
    required this.onTap,
  }) : super(key: key);

  final EdgeInsets margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AlbumOptionsModel, bool>(
        selector: (_, model) => model.canShowReportAlbumOption,
        builder: (_, canShowReportAlbumOption, __) {
          if (!canShowReportAlbumOption) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: margin,
              text: LocaleResources.of(context).report,
              onTap: onTap);
        });
  }
}
