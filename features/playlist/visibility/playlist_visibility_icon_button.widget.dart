import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

import 'playlist_visibility_support.widget.dart';

class PlaylistVisibilityIconButton extends PlaylistVisibilityStatefulWidget {
  const PlaylistVisibilityIconButton({
    Key? key,
    required Playlist playlist,
  }) : super(key: key, playlist: playlist);

  @override
  State<PlaylistVisibilityIconButton> createState() =>
      _PlaylistVisibilityToggleWidgetState();
}

class _PlaylistVisibilityToggleWidgetState
    extends PlaylistVisibilityState<PlaylistVisibilityIconButton> {
  //=

  @override
  Widget build(BuildContext context) {
    final isPublic = isPlaylistPublic;
    return AppIconButton(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        assetColor: DynamicTheme.get(context).white(),
        assetPath: isPublic ? Assets.iconPublic : Assets.iconLock,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: onToggleVisibilityTap);
  }
}
