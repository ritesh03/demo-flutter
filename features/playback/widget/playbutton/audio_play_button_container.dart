import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class AudioPlayButtonContainer extends StatelessWidget {
  const AudioPlayButtonContainer({
    Key? key,
    required this.size,
    required this.isInScope,
    required this.state,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  final double size;
  final bool isInScope;
  final PlayerPlayState state;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      opacityMinValue: 1.0,
      onPressed: _onTap,
      child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                      DynamicTheme.get(context).primaryDecorationAssetPath()))),
          child: child),
    );
  }

  void _onTap() {
    if (!isInScope) {
      onTap();
      return;
    }

    switch (state) {
      case PlayerPlayState.loading:
        return;
      case PlayerPlayState.paused:
        audioPlayerManager.play();
        return;
      case PlayerPlayState.playing:
        audioPlayerManager.pause();
        return;
    }
  }
}
