import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_tile_item.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/video_page_interface.dart';
import 'package:kwotmusic/navigation/dashboard_navigation.dart';
import 'package:kwotmusic/navigation/root_navigation.dart';
import 'package:kwotmusic/router/routes.dart';

class VideoPageArtistBar extends StatelessWidget {
  const VideoPageArtistBar({
    Key? key,
    required this.pageInterface,
  }) : super(key: key);

  final VideoPageInterface pageInterface;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Artist?>(
        valueListenable: pageInterface.artistNotifier,
        builder: (context, artist, __) {
          if (artist == null) return Container();
          return ArtistTileItem(
            artist: artist,
            onTap: () => _onArtistTap(context, artist: artist),
            onFollowTap: () => _onFollowButtonTap(context, artist: artist),
          );
        });
  }

  void _onArtistTap(
    BuildContext context, {
    required Artist artist,
  }) {
    RootNavigation.popUntilRoot(context);

    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onFollowButtonTap(
    BuildContext context, {
    required Artist artist,
  }) async {
    showBlockingProgressDialog(context);

    final result = await locator<ArtistActionsModel>().setIsFollowed(
      id: artist.id,
      shouldFollow: !artist.isFollowed,
    );
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }
}
