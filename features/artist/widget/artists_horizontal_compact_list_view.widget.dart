import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class ArtistsHorizontalCompactListView extends StatelessWidget {
  const ArtistsHorizontalCompactListView({
    Key? key,
    required this.artists,
    required this.padding,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);

  final List<Artist> artists;
  final EdgeInsets padding;
  final ValueSetter<Artist> onTap;
  final ValueSetter<Artist> onFollowTap;

  @override
  Widget build(BuildContext context) {
    final height = ComponentSize.large.r;
    return SizedBox(
      height: height,
      child: ListView.separated(
          separatorBuilder: (_, __) => SizedBox(width: ComponentInset.normal.r),
          itemCount: artists.length,
          padding: padding,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return _ArtistCompactWidget(
                artist: artist,
                height: height,
                onTap: () => onTap(artist),
                onFollowTap: () => onFollowTap(artist));
          }),
    );
  }
}

class _ArtistCompactWidget extends StatelessWidget {
  const _ArtistCompactWidget({
    Key? key,
    required this.artist,
    required this.height,
    required this.onTap,
    required this.onFollowTap,
  }) : super(key: key);

  final Artist artist;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final thumbnailSize = height;
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// THUMBNAIL
          ScaleTap(
            onPressed: onTap,
            child: Photo.artist(
              artist.thumbnail,
              options: PhotoOptions(
                width: thumbnailSize,
                height: thumbnailSize,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: ComponentInset.small.w),

          /// BODY | CONTENT
          ScaleTap(
              scaleMinValue: 1.0,
              opacityMinValue: 0.86,
              onPressed: onTap,
              child: Container(
                  color: Colors.transparent,
                  child: _ArtistCompactBodyWidget(
                    artist: artist,
                    onFollowTap: onFollowTap,
                  ))),
          SizedBox(width: ComponentInset.small.w),
        ]);
  }
}

class _ArtistCompactBodyWidget extends StatelessWidget {
  const _ArtistCompactBodyWidget({
    Key? key,
    required this.artist,
    required this.onFollowTap,
  }) : super(key: key);

  final Artist artist;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final followerCountStr = LocaleResources.of(context).followerCountFormat(
        artist.followerCount, artist.followerCount.prettyCount);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ARTIST NAME + FOLLOW BUTTON
          SizedBox(
              height: ComponentSize.smaller.r,
              child: _ArtistNameWithFollowButton(
                  artist: artist, onFollowTap: onFollowTap)),

          /// FOLLOWER COUNT
          Text(followerCountStr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.heading6
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ]);
  }
}

class _ArtistNameWithFollowButton extends StatelessWidget {
  const _ArtistNameWithFollowButton({
    Key? key,
    required this.artist,
    required this.onFollowTap,
  }) : super(key: key);

  final Artist artist;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      /// ARTIST NAME
      Text("${artist.name} · ",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody
              .copyWith(color: DynamicTheme.get(context).white())),

      /// ARTIST FOLLOW BUTTON
      Button(
        onPressed: onFollowTap,
        overriddenForegroundColor: artist.isFollowed
            ? DynamicTheme.get(context).neutral10()
            : DynamicTheme.get(context).secondary100(),
        text: artist.isFollowed
            ? LocaleResources.of(context).unfollow
            : LocaleResources.of(context).follow,
        type: ButtonType.text,
      )
    ]);
  }
}
