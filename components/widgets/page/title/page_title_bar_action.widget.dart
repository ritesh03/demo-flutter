import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class PageTitleIconAction extends StatelessWidget {
  const PageTitleIconAction({
    Key? key,
    required this.asset,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final String asset;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        margin: EdgeInsets.only(right: ComponentInset.small.r),
        assetColor: color,
        assetPath: asset,
        onPressed: onTap);
  }
}
