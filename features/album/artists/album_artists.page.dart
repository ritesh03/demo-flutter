import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/album/widget/album_compact_preview.widget.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/profile/artist.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

class AlbumArtistsArgs {
  AlbumArtistsArgs({
    required this.album,
  });

  final Album album;
}

class AlbumArtistsPage extends StatefulWidget {
  const AlbumArtistsPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  final AlbumArtistsArgs args;

  @override
  State<AlbumArtistsPage> createState() => _AlbumArtistsPageState();
}

class _AlbumArtistsPageState extends State<AlbumArtistsPage> {
  //=
  late List<Artist> _artists;
  late StreamSubscription _eventsSubscription;

  @override
  void initState() {
    super.initState();

    _artists = widget.args.album.artists;
    _eventsSubscription = eventBus
        .on<ArtistFollowUpdatedEvent>()
        .listen(_handleArtistFollowUpdates);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.r),
                child: const _AlbumArtistsAppBar()),
            body: Column(children: [
              Padding(
                  padding: EdgeInsets.all(ComponentInset.normal.r),
                  child: AlbumCompactPreview(album: widget.args.album)),
              const _Divider(),
              Expanded(
                child: ListView.separated(
                    itemCount: _artists.length,
                    padding: EdgeInsets.all(ComponentInset.normal.r),
                    itemBuilder: (_, index) {
                      final artist = _artists[index];
                      return ArtistListItem(
                        artist: artist,
                        onTap: () => _onArtistTapped(artist),
                        onFollowTap: () => _onArtistFollowTapped(artist),
                      );
                    },
                    separatorBuilder: (_, index) {
                      return SizedBox(height: ComponentInset.normal.r);
                    }),
              ),
            ])));
  }

  void _onArtistTapped(Artist artist) {
    final args = ArtistPageArgs.object(artist: artist);
    DashboardNavigation.pushNamed(context, Routes.artist, arguments: args);
  }

  void _onArtistFollowTapped(Artist artist) async {
    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<ArtistActionsModel>().setIsFollowed(
      id: artist.id,
      shouldFollow: !artist.isFollowed,
    );

    // Close loading dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess() || result.isEmpty()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _handleArtistFollowUpdates(ArtistFollowUpdatedEvent event) {
    final artists = _artists.toList();
    final index = artists.indexWhere((element) => element.id == event.artistId);
    if (index < 0) return;

    setState(() {
      artists[index] = event.update(_artists[index]);
      _artists = artists;
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }
}

class _AlbumArtistsAppBar extends StatelessWidget {
  const _AlbumArtistsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(children: [
        AppIconButton(
            width: ComponentSize.large.r,
            height: ComponentSize.large.r,
            assetColor: DynamicTheme.get(context).neutral20(),
            assetPath: Assets.iconArrowLeft,
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: () => DashboardNavigation.pop(context)),
        const Spacer(),
        SizedBox(width: ComponentInset.small.w)
      ]),
      Center(
        child: Text(LocaleResources.of(context).albumArtistsPageTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading5
                .copyWith(color: DynamicTheme.get(context).white())),
      )
    ]);
  }
}

class _Divider extends StatelessWidget {
  const _Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DynamicTheme.get(context).black(),
      height: 2.r,
      margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
    );
  }
}
