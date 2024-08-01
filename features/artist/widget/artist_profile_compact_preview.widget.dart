import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class ArtistProfileCompactPreview extends StatelessWidget {
  const ArtistProfileCompactPreview({
    Key? key,
    required this.artist,
    this.margin,
    this.padding,
  }) : super(key: key);

  final Artist artist;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(children: [
          _buildProfilePhoto(),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  _buildSubtitle(context),
                ]),
          )
        ]));
  }

  Widget _buildProfilePhoto() {
    return Photo.artist(
      artist.thumbnail,
      options: PhotoOptions(
        width: 104.r,
        height: 104.r,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(artist.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
        LocaleResources.of(context).followerCountFormat(
            artist.followerCount, artist.followerCount.prettyCount),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading5
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}