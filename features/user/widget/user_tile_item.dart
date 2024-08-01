import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class UserTileItem extends StatelessWidget {
  const UserTileItem({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);

  final User user;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      scaleMinValue: 1.0,
      opacityMinValue: 0.8,
      onPressed: onTap,
      child: Container(
          color: Colors.transparent,
          height: ComponentSize.large.r,
          child: Row(children: [
            _UserPhoto(user: user, onTap: onTap),
            SizedBox(width: ComponentInset.small.r),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UserName(name: user.name),
                    _UserFollowerCount(count: user.followerCount),
                  ]),
            ),
            SizedBox(width: ComponentInset.small.r),
            _UserFollowButton(user: user, onTap: onFollowTap)
          ])),
    );
  }
}

class _UserPhoto extends StatelessWidget {
  const _UserPhoto({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.large.r;
    return ScaleTap(
        onPressed: onTap,
        child: Photo.user(user.thumbnail,
            options: PhotoOptions(
              width: size,
              height: size,
              shape: BoxShape.circle,
            )));
  }
}

class _UserName extends StatelessWidget {
  const _UserName({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _UserFollowerCount extends StatelessWidget {
  const _UserFollowerCount({
    Key? key,
    required this.count,
  }) : super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
        LocaleResources.of(context)
            .followerCountFormat(count, count.prettyCount),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}

class _UserFollowButton extends StatelessWidget {
  const _UserFollowButton({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (user.isBlocked) return const SizedBox.shrink();
    return Button(
      onPressed: onTap,
      overriddenForegroundColor: user.isFollowed
          ? DynamicTheme.get(context).neutral10()
          : DynamicTheme.get(context).secondary100(),
      text: user.isFollowed
          ? LocaleResources.of(context).unfollow
          : LocaleResources.of(context).follow,
      type: ButtonType.text,
    );
  }
}
