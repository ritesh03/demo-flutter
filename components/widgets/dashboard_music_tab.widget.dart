import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';

/// Used to be highlighted music-tab in dashboard bottom-tabs
class DashboardMusicTabWidget extends StatelessWidget {
  const DashboardMusicTabWidget({
    Key? key,
    required this.isSelected,
  }) : super(key: key);

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = 64.r;
    final iconSize = 36.r;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: obtainBackgroundColor(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(alignment: Alignment.center, children: [
        if (isSelected)
          Image.asset(
            DynamicTheme.get(context).primaryDecorationAssetPath(),
            width: size,
            height: size,
            cacheWidth: size.toInt(),
            cacheHeight: size.toInt(),
          ),
        SizedBox(
            width: iconSize,
            height: iconSize,
            child: SvgPicture.asset(
              Assets.iconMusicNote,
              color: isSelected
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              width: iconSize,
              height: iconSize,
            ))
      ]),
    );
  }

  Color? obtainBackgroundColor(BuildContext context) {
    return isSelected ? null : DynamicTheme.get(context).black();
  }
}
