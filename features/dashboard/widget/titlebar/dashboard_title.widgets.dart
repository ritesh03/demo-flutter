import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';

class DashboardPageTitle extends StatelessWidget {
  const DashboardPageTitle({
    Key? key,
    required this.text,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading5.copyWith(color: color)),
    );
  }
}

class DashboardPageTitleAction extends StatelessWidget {
  const DashboardPageTitleAction({
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
