import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';

class AudioPlayButtonContent extends StatelessWidget {
  const AudioPlayButtonContent({
    Key? key,
    required this.foregroundColor,
    required this.iconPadding,
    required this.iconSize,
    required this.isInScope,
    required this.state,
  }) : super(key: key);

  final Color foregroundColor;
  final EdgeInsets iconPadding;
  final double iconSize;
  final bool isInScope;
  final PlayerPlayState state;

  @override
  Widget build(BuildContext context) {
    if (!isInScope) {
      return SvgAssetPhoto(
        Assets.iconPlay,
        width: iconSize,
        height: iconSize,
        color: foregroundColor,
        padding: iconPadding,
      );
    }

    switch (state) {
      case PlayerPlayState.loading:
        return CircularProgressIndicator(
          strokeWidth: 2.r,
          color: foregroundColor,
        );
      case PlayerPlayState.paused:
        return SvgAssetPhoto(
          Assets.iconPlay,
          width: iconSize,
          height: iconSize,
          color: foregroundColor,
          padding: iconPadding,
        );
      case PlayerPlayState.playing:
        return SvgAssetPhoto(
          Assets.iconPause,
          width: iconSize,
          height: iconSize,
          color: foregroundColor,
          padding: iconPadding,
        );
    }
  }
}
