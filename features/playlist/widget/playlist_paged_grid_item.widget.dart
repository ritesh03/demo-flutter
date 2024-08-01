import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/playback_source_play_button.widget.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PlaylistPagedGridItem extends StatelessWidget {
  const PlaylistPagedGridItem({
    Key? key,
    required this.playlist,
    required this.onTap,
  }) : super(key: key);

  final Playlist playlist;
  final Function(Playlist) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(playlist),
        child: Container(

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(context),
                  SizedBox(height: ComponentInset.small.r),
                  _buildTitle(context),
                ])));
  }

  Widget _buildThumbnail(BuildContext context) {
    // Design aspect ratio is 256x256 (1)
    return AspectRatio(
        aspectRatio: 1,
        child: Stack(fit: StackFit.expand, children: [
          Photo.playlist(
            playlist.images.isEmpty ? null : playlist.images.first,
            options: PhotoOptions(
                width: 256.r,
                height: 256.r,
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
          ),
          Positioned(
              bottom: ComponentInset.small.r,
              right: ComponentInset.small.r,
              child: _PlaylistPlayButton(
                  playlist: playlist, size: ComponentSize.small.r))
        ]));
  }

  Widget _buildTitle(BuildContext context) {
    final text = locator<PlaylistActionsModel>()
        .generateCompactPlaylistSubtitle(context,
            duration: playlist.duration, trackCount: playlist.totalTracks);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).neutral10()),
    );
  }
}

class _PlaylistPlayButton extends StatelessWidget {
  const _PlaylistPlayButton({
    Key? key,
    required this.playlist,
    required this.size,
  }) : super(key: key);

  final Playlist playlist;
  final double size;

  @override
  Widget build(BuildContext context) {
    return PlaybackSourcePlayButton(
      scopeId: playlist.id,
      size: size,
      iconSize: size,
      outOfScopeChild: Button(
          height: ComponentSize.small.r,
          onPressed: _onTap,
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          text: LocaleResources.of(context).playlistStartPlaybackAction,
          type: ButtonType.secondary),
      onTap: _onTap,
    );
  }

  void _onTap() async {
    final result =
        await locator<AudioPlaybackActionsModel>().playPlaylist(playlist.id);
    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}
