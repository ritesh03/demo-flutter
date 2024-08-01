import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class VideoPageTopBar extends StatelessWidget {
  const VideoPageTopBar({
    Key? key,
    required this.onBackTap,
  }) : super(key: key);

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      /// BACK BUTTON
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).white(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: onBackTap),
    ]);
  }
}
