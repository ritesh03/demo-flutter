import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class PlaybackSeekForwardButton extends StatelessWidget {
  const PlaybackSeekForwardButton({
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
        builder: (_, canSeekForward, __) {
          if (canSeekForward == null) return Container();
          return AppIconButton(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              assetColor: canSeekForward
                  ? DynamicTheme.get(context).neutral10()
                  : DynamicTheme.get(context).neutral60(),
              assetPath: Assets.iconForward15,
              onPressed: onTap);
        });
  }
}
