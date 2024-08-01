import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class PlaybackPreviousItemButton extends StatelessWidget {
  const PlaybackPreviousItemButton({
    Key? key,
    required this.notifier,
    required this.onTap,
  }) : super(key: key);

  final ValueNotifier<bool?> notifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
        valueListenable: notifier,
        builder: (_, canPlayPreviousItem, __) {
          if (canPlayPreviousItem == null) return Container();
          return AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: canPlayPreviousItem
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral40(),
              assetPath: Assets.iconPlaybackLast,
              onPressed: onTap);
        });
  }
}
