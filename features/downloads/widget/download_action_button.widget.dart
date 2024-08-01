import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class DownloadActionButton extends StatelessWidget {
  const DownloadActionButton({
    Key? key,
    required this.iconPath,
    required this.onTap,
  }) : super(key: key);

  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.normal.r,
        assetColor: DynamicTheme.get(context).neutral20(),
        assetPath: iconPath,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: onTap);
  }
}
