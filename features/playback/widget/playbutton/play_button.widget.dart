import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/util/tuple_value_notifier.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key? key,
    required this.notifier,
    required this.onPlayTap,
    required this.onPauseTap,
    this.compact = false,
    required this.size,
    this.iconSize,
    this.scopeId,
    this.hideOnScopeMismatch = false,
    this.hideIfNotPlaying = false,
    this.onScopedPlayTap,
  }) : super(key: key);

  final PlayerPlayStateNotifier notifier;
  final VoidCallback onPlayTap;
  final VoidCallback onPauseTap;
  final bool compact;
  final double size;
  final double? iconSize;
  final String? scopeId;
  final bool hideOnScopeMismatch;
  final bool hideIfNotPlaying;
  final VoidCallback? onScopedPlayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Tuple2ValueListenableBuilder<String?, PlayerPlayState>(
          valueListenable: notifier,
          builder: (_, tuple, __) {
            final identifier = tuple.item1;
            final state = tuple.item2;

            if (hideIfNotPlaying && state == PlayerPlayState.paused) {
              return Container();
            }

            if (scopeId != null && scopeId != identifier) {
              if (hideOnScopeMismatch) {
                return Container();
              }
            }

            return compact
                ? _buildCompactButton(context, identifier, state)
                : _buildButton(context, identifier, state);
          }),
    );
  }

  Widget _buildCompactButton(
    BuildContext context,
    String? identifier,
    PlayerPlayState state,
  ) {
    final iconSize = this.iconSize ?? size;

    if (scopeId != null && scopeId != identifier) {
      return AppIconButton(
          width: iconSize,
          height: iconSize,
          assetPath: Assets.iconPlay,
          assetColor: DynamicTheme.get(context).white(),
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: onScopedPlayTap);
    }

    switch (state) {
      case PlayerPlayState.loading:
        return SizedBox(
            width: ComponentSize.smallest.r,
            height: ComponentSize.smallest.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              color: DynamicTheme.get(context).white(),
            ));
      case PlayerPlayState.paused:
        return AppIconButton(
            width: iconSize,
            height: iconSize,
            assetPath: Assets.iconPlay,
            assetColor: DynamicTheme.get(context).white(),
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: onPlayTap);
      case PlayerPlayState.playing:
        return AppIconButton(
            width: iconSize,
            height: iconSize,
            assetPath: Assets.iconPause,
            assetColor: DynamicTheme.get(context).white(),
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: onPauseTap);
    }
  }

  Widget _buildButton(
    BuildContext context,
    String? identifier,
    PlayerPlayState state,
  ) {
    final decorationImage = DecorationImage(
        fit: BoxFit.fill,
        image: AssetImage(
          DynamicTheme.get(context).primaryDecorationAssetPath(),
        ));

    return Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(shape: BoxShape.circle, image: decorationImage),
        child: _buildCompactButton(context, identifier, state));
  }
}
