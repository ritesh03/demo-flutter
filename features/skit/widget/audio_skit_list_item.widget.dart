import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class AudioSkitListItem extends StatelessWidget {
  const AudioSkitListItem({
    Key? key,
    required this.skit,
    required this.onTap,
    required this.onOptionsTap,
  }) : super(key: key);

  final Skit skit;
  final Function(Skit skit) onTap;
  final Function(Skit skit) onOptionsTap;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _buildContent(context)),
      _buildOptionsButton(context)
    ]);
  }

  Widget _buildContent(BuildContext context) {
    final height = 72.r;
    return ScaleTap(
        onPressed: () => onTap(skit),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _buildThumbnail(context, size: height),
            SizedBox(width: ComponentInset.small.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitle(context),
                    _buildArtistName(context),
                    const Spacer(),
                    _buildInfo(context),
                  ]),
            ),
            SizedBox(width: ComponentInset.small.w),
          ]),
        ));
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required double size,
  }) {
    final radius = ComponentRadius.normal.r;
    return Stack(children: [
      /// SKIT PHOTO
      Photo.skit(
        skit.thumbnail,
        options: PhotoOptions(
            width: size,
            height: size,
            borderRadius: BorderRadius.circular(radius)),
      ),

      /// SKIT DURATION
      Positioned(
          bottom: 0, right: 0, child: _buildDuration(context, radius: radius))
    ]);
  }

  Widget _buildDuration(
    BuildContext context, {
    required double radius,
  }) {
    final durationText = skit.duration.toHoursMinutesSeconds();
    if (durationText == null) {
      return Container();
    }

    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: DynamicTheme.displayBlack.withOpacity(0.5),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                bottomRight: Radius.circular(radius))),
        padding: EdgeInsets.symmetric(
            horizontal: ComponentInset.smaller.r,
            vertical: ComponentInset.smaller.r / 2),
        child: Text(durationText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldCaption
                .copyWith(color: DynamicTheme.get(context).white())));
  }

  Widget _buildTitle(BuildContext context) {
    return Text(skit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildArtistName(BuildContext context) {
    return Text(skit.artist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }

  Widget _buildInfo(BuildContext context) {
    final localization = LocaleResources.of(context);
    final viewsText =
        localization.integerViewCountFormat(skit.views, skit.views.prettyCount);
    final dateText = skit.createdAt.toDefaultDateFormat();
    return Text("$viewsText · $dateText",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.lightHeading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }

  Widget _buildOptionsButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.small.r,
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: () => onOptionsTap(skit));
  }
}