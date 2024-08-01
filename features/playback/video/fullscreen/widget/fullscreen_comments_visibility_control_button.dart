import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'fullscreen_icon_control_button.dart';

class FullScreenCommentsVisibilityControlButton extends StatelessWidget {
  const FullScreenCommentsVisibilityControlButton({
    Key? key,
    required this.notifier,
    required this.onTap,
  }) : super(key: key);

  final ValueNotifier<bool> notifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (_, visible, __) {
          return FullScreenIconControlButton(
              size: ComponentSize.large.r,
              assetPath: Assets.iconComments,
              color: visible
                  ? DynamicTheme.get(context).secondary100()
                  : DynamicTheme.get(context).white(),
              onTap: onTap);
        });
  }
}
