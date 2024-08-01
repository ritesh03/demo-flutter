import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'fullscreen_icon_control_button.dart';

class FullScreenDislikeControlButton extends StatelessWidget {
  const FullScreenDislikeControlButton({
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
        builder: (_, disliked, __) {
          return FullScreenIconControlButton(
              size: ComponentSize.large.r,
              assetPath: (disliked ?? false)
                  ? Assets.iconDislikeFilled
                  : Assets.iconDislike,
              onTap: onTap);
        });
  }
}
