import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/app_bottomsheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/playlist/createedit/create_edit_playlist.model.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';
import 'package:kwotmusic/features/playlist/tracks/add/trackexists/track_exists_in_playlist.bottomsheet.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'add_to_playlist.model.dart';

class AddToPlaylistBottomSheet extends StatefulWidget {
  //=
  static Future<void> forTrack(BuildContext context, Track track) {
    return AppBottomSheet.show<Track, AddToPlaylistModel>(
      context,
      changeNotifier: AddToPlaylistModel.track(track),
      builder: (context, controller) {
        return AddToPlaylistBottomSheet(controller: controller);
      },
    );
  }

  static Future<void> forAlbum(BuildContext context, Album album) {
    return AppBottomSheet.show<Album, AddToPlaylistModel>(
      context,
      changeNotifier: AddToPlaylistModel.album(album),
      builder: (context, controller) {
        return AddToPlaylistBottomSheet(controller: controller);
      },
    );
  }

  const AddToPlaylistBottomSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ScrollController controller;

  @override
  State<AddToPlaylistBottomSheet> createState() =>
      _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends State<AddToPlaylistBottomSheet> {
  //=

  AddToPlaylistModel get _model => context.read<AddToPlaylistModel>();

  @override
  void initState() {
    super.initState();
    _model.init();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.r),
      Align(
          alignment: Alignment.center,
          child: Text(localization.playlistChooserTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldBody)),
      SizedBox(height: ComponentInset.medium.r),
      SearchBar(
          margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          backgroundColor: DynamicTheme.get(context).background(),
          hintText: localization.playlistChooserSearchHint,
          onQueryChanged: _model.updateSearchQuery,
          onQueryCleared: _model.clearSearchQuery),
      Button(
        width: double.infinity,
        height: ComponentSize.large.r,
        margin: EdgeInsets.only(
            left: ComponentInset.normal.r,
            top: ComponentInset.medium.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.small.r),
        onPressed: _onCreatePlaylistTap,
        text: localization.createPlaylist,
        type: ButtonType.primary,
      ),
      Expanded(
        child: _PlaylistsList(
          controller: widget.controller,
          onPlaylistTap: _onPlaylistTap,
        ),
      ),
    ]);
  }

  void _onCreatePlaylistTap() {
    hideKeyboard(context);
    RootNavigation.popUntilRoot(context);

    DashboardNavigation.pushNamed(
      context,
      Routes.createOrEditPlaylist,
      arguments: CreatePlaylistArgs(
        initialTrack: _model.track,
        initialAlbum: _model.album,
      ),
    );
  }

  void _onPlaylistTap(Playlist playlist) {
    final album = _model.album;
    if (album != null) {
      _addAlbumToPlaylist(playlist, album);
      return;
    }

    final track = _model.track;
    if (track != null) {
      _addTrackToPlaylist(playlist, track);
      return;
    }

    throw Exception("Unable to determine what to add to the playlist.");
  }

  void _addAlbumToPlaylist(Playlist playlist, Album album) async {
    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().addAlbum(
      playlistId: playlist.id,
      album: album,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    RootNavigation.popUntilRoot(context);
  }

  void _addTrackToPlaylist(
    Playlist playlist,
    Track track, {
    bool allowDuplicate = false,
  }) async {
    showBlockingProgressDialog(context);

    final result = await locator<PlaylistActionsModel>().addTrack(
      playlistId: playlist.id,
      track: track,
      allowDuplicate: allowDuplicate,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      if (result.errorCode() ==
          ErrorCodes.playlistUpdateFailedWhenTrackExists) {
        _handleOnAddDuplicateTrackAttempted(playlist, track);
        return;
      }

      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    RootNavigation.popUntilRoot(context);
  }

  void _handleOnAddDuplicateTrackAttempted(
    Playlist playlist,
    Track track,
  ) async {
    final shouldAddDuplicateTrack =
        await TrackExistsInPlaylistBottomSheet.show(context);

    if (!mounted) return;
    if (shouldAddDuplicateTrack != null && shouldAddDuplicateTrack) {
      _addTrackToPlaylist(playlist, track, allowDuplicate: true);
    }
  }
}

class _PlaylistsList extends StatelessWidget {
  const _PlaylistsList({
    Key? key,
    required this.controller,
    required this.onPlaylistTap,
  }) : super(key: key);

  final ScrollController controller;
  final Function(Playlist) onPlaylistTap;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<Playlist, AddToPlaylistModel>(
        controller: controller,
        columnItemSpacing: ComponentInset.normal.r,
        padding: EdgeInsets.all(ComponentInset.normal.r),
        useRefreshIndicator: false,
        itemBuilder: (context, playlist, index) {
          return PlaylistListItem(
            playlist: playlist,
            onTap: () => onPlaylistTap(playlist),
          );
        });
  }
}
