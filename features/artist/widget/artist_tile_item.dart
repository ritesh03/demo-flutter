import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class ArtistTileItem extends StatelessWidget {
  const ArtistTileItem({
    Key? key,
    required this.artist,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);

  final Artist artist;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: ComponentSize.large.h,
        child: Row(children: [
          _buildPhoto(context),
          Expanded(child: _buildTitleAndFollowers(context)),
          _buildFollowButton(context)
        ]));
  }

  Widget _buildPhoto(BuildContext context) {
    final size = ComponentSize.large.h;
    return ScaleTap(
      onPressed: onTap,
      child: Photo.artist(
        artist.thumbnail,
        options: PhotoOptions(
          width: size,
          height: size,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTitleAndFollowers(BuildContext context) {
    return ScaleTap(
        scaleMinValue: 1.0,
        opacityMinValue: 0.6,
        onPressed: onTap,
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                SizedBox(
                    height: ComponentSize.smaller.h,
                    child: Text(artist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.boldBody.copyWith(
                            color: DynamicTheme.get(context).white()))),

                /// FOLLOWER COUNT
                SizedBox(
                    height: ComponentSize.smallest.h,
                    child: Text(
                        LocaleResources.of(context).followerCountFormat(
                            artist.followerCount,
                            artist.followerCount.prettyCount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.heading6.copyWith(
                            color: DynamicTheme.get(context).neutral10()))),
              ]),
        ));
  }

  Widget _buildFollowButton(BuildContext context) {
    return Button(
      onPressed: onFollowTap,
      overriddenForegroundColor: artist.isFollowed
          ? DynamicTheme.get(context).neutral10()
          : DynamicTheme.get(context).secondary100(),
      text: artist.isFollowed
          ? LocaleResources.of(context).unfollow
          : LocaleResources.of(context).follow,
      type: ButtonType.text,
    );
  }
}
