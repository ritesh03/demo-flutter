import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class ProfileStatItem extends StatelessWidget {
  const ProfileStatItem({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = (onTap == null);
    final titleTextColor = disabled
        ? DynamicTheme.get(context).neutral40()
        : DynamicTheme.get(context).white();
    final subtitleTextColor = disabled
        ? DynamicTheme.get(context).neutral40()
        : DynamicTheme.get(context).neutral20();
    return ScaleTap(
        onPressed: onTap,
        child: Container(
            decoration: BoxDecoration(
                color: DynamicTheme.get(context).secondary10(),
                borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
            child: Column(children: [
              SizedBox(height: ComponentInset.normal.h),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyles.boldHeading3.copyWith(color: titleTextColor)),
              SizedBox(height: ComponentInset.small.h),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.body.copyWith(color: subtitleTextColor)),
              SizedBox(height: ComponentInset.normal.h)
            ])));
  }
}
