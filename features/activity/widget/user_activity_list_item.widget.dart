import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';

class UserActivityListItem extends StatelessWidget {
  const UserActivityListItem({
    Key? key,
    required this.activity,
    required this.onTap,
  }) : super(key: key);

  final UserActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _buildContent(context)),
      _buildArrowIcon(context)
    ]);
  }

  Widget _buildContent(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        scaleMinValue: 0.99,
        opacityMinValue: 0.7,
        child: Container(
            color: Colors.transparent,
            child: Row(children: [
              _buildPhoto(),
              SizedBox(width: ComponentInset.small.w),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitle(context),
                      _buildSummary(context),
                    ]),
              ),
            ])));
  }

  Widget _buildPhoto() {
    return Photo.user(
      activity.user.thumbnail,
      options: PhotoOptions(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          shape: BoxShape.circle),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smaller.h,
      child: Text(activity.user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody
              .copyWith(color: DynamicTheme.get(context).white())),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smallest.h,
      child: Text(activity.summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10())),
    );
  }

  Widget _buildArrowIcon(BuildContext context) {
    return SvgAssetPhoto(
      Assets.iconArrowRight,
      width: ComponentSize.normal.r,
      height: ComponentSize.smaller.r,
      color: DynamicTheme.get(context).neutral10(),
    );
  }
}
