import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/playlist/playlist_actions.model.dart';

import 'change_playlist_visibility_confirmation.bottomsheet.dart';

enum _VisibilityState { public, private, loadingPublic, loadingPrivate }

abstract class PlaylistVisibilityStatefulWidget extends StatefulWidget {
  const PlaylistVisibilityStatefulWidget({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  final Playlist playlist;
}

abstract class PlaylistVisibilityState<
    T extends PlaylistVisibilityStatefulWidget> extends State<T> {
  late _VisibilityState _visibilityState;

  bool get isPlaylistPublic {
    switch (_visibilityState) {
      case _VisibilityState.public:
      case _VisibilityState.loadingPublic:
        return true;
      case _VisibilityState.private:
      case _VisibilityState.loadingPrivate:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _visibilityState = widget.playlist.public
        ? _VisibilityState.public
        : _VisibilityState.private;
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    if (widget.playlist.id != oldWidget.playlist.id ||
        widget.playlist.public != oldWidget.playlist.public) {
      final newState = widget.playlist.public
          ? _VisibilityState.public
          : _VisibilityState.private;
      _updateState(newState);
    }

    super.didUpdateWidget(oldWidget);
  }

  void onToggleVisibilityTap() async {
    bool shouldSetPublic;
    final oldVisibilityState = _visibilityState;
    final _VisibilityState newState;
    switch (oldVisibilityState) {
      case _VisibilityState.loadingPrivate:
      case _VisibilityState.loadingPublic:
        return;
      case _VisibilityState.public:
        shouldSetPublic = false;
        newState = _VisibilityState.loadingPrivate;
        break;
      case _VisibilityState.private:
        shouldSetPublic = true;
        newState = _VisibilityState.loadingPublic;
        break;
    }

    bool? shouldContinue = await ChangePlaylistVisibilityConfirmationBottomSheet.show(context, makingPublic: shouldSetPublic,);
    if (!mounted) return;
    if (shouldContinue == null || !shouldContinue) {
      return;
    }

    _updateState(newState);

    final result =
        await locator<PlaylistActionsModel>().updatePlaylistVisibility(
      playlistId: widget.playlist.id,
      public: shouldSetPublic,
    );
    if (!result.isSuccess()) {
      _updateState(oldVisibilityState);
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    final _VisibilityState updatedState;
    switch (newState) {
      case _VisibilityState.loadingPrivate:
      case _VisibilityState.private:
        updatedState = _VisibilityState.private;
        break;
      case _VisibilityState.loadingPublic:
      case _VisibilityState.public:
        updatedState = _VisibilityState.public;
        break;
    }
    _updateState(updatedState);

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));
  }

  void onUpdateVisibilityTap({
    required bool makePublic,
  }) {
    if (isPlaylistPublic == makePublic) return;
    onToggleVisibilityTap();
  }

  void _updateState(_VisibilityState state) {
    setState(() => _visibilityState = state);
  }
}
