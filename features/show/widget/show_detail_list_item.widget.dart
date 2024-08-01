import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/glow/glow.widget.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'show_duration.widget.dart';

class ShowDetailListItem extends StatelessWidget {
  const ShowDetailListItem({
    Key? key,
    required this.show,
    required this.onTap,
    required this.onReminderButtonTap,
    required this.onOptionsButtonTap,
  }) : super(key: key);

  final Show show;
  final Function(Show show) onTap;
  final Function(Show show) onReminderButtonTap;
  final Function(Show show) onOptionsButtonTap;

  @override
  Widget build(BuildContext context) {
    return TappableButton(
        overlayColor: Colors.transparent,
        onTap: () => onTap(show),
        child: Container(

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContent(context),
                  _buildFooter(context),
                ])));
  }

  Widget _buildContent(BuildContext context) {
    return Stack(children: [
      /// Show glowness behind items
      Glow(spreadRadius: 24.r),

      /// Show artwork
      // Design aspect ratio is 374 x 216 (1.74)
      AspectRatio(
          aspectRatio: 1.74,
          child: Photo.show(
            show.thumbnail,
            options: PhotoOptions(height: 216.r),
          )),

      /// If Show is livestreaming, show livestream indicator.
      if (show.isStreamingNow)
        Positioned(top: 0, left: 0, child: _buildLivestreamIndicator(context)),

      /// If Show is yet to start, show start date.
      if (!show.isStreamingNow)
        Positioned(top: 0, left: 0, child: _buildShowDateTime(context)),

      /// If Show is paid, but not purchased, show ticket price
      if (show.isPaid && !show.isPurchased)
        Positioned(
          top: 0,
          right: 0,
          child: _buildTicketPrice(context, height: ComponentSize.small.r),
        ),

      /// If following conditions are true, show reminder
      /// 1. Show is not streaming now
      /// 2. Show is free or [paid and purchased]
      if (!show.isStreamingNow &&
          (!show.isPaid || (show.isPaid && show.isPurchased)))
        Positioned(
          top: 0,
          right: 0,
          child: _buildRemindMeButton(context, height: ComponentSize.small.r),
        ),

      /// Show's duration
      Positioned(bottom: 0, right: 0, child: ShowDurationWidget(show: show)),
    ]);
  }

  Widget _buildLivestreamIndicator(BuildContext context) {
    final iconSize = ComponentSize.small.r;
    return Container(
        height: iconSize,
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).white(), shape: BoxShape.circle),
        margin: EdgeInsets.all(ComponentInset.small.r),
        child: SvgPicture.asset(
          Assets.iconLive,
          width: iconSize,
          height: iconSize,
          color: DynamicTheme.get(context).error100(),
        ));
  }

  Widget _buildShowDateTime(BuildContext context) {
    final formattedText = DateFormat('dd/MM/yyyy').format(show.startDateTime);
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: DynamicTheme.displayBlack.withOpacity(0.5),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        margin: EdgeInsets.all(ComponentInset.small.r),
        padding: EdgeInsets.symmetric(
            horizontal: ComponentInset.small.r,
            vertical: ComponentInset.smaller.r),
        height: ComponentSize.small.h,
        child: Text(formattedText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.body
                .copyWith(color: DynamicTheme.get(context).white())));
  }

  Widget _buildTicketPrice(
    BuildContext context, {
    required double height,
  }) {
    return Container(
      alignment: Alignment.center,
      height: height,
      decoration: BoxDecoration(
        color: DynamicTheme.displayBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
      margin: EdgeInsets.all(ComponentInset.small.r),
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.r),
      child: Text(show.price,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading5
              .copyWith(color: DynamicTheme.get(context).white())),
    );
  }

  Widget _buildRemindMeButton(
    BuildContext context, {
    required double height,
  }) {
    return AppIconTextButton(
        axis: Axis.horizontal,
        color: DynamicTheme.get(context).white(),
        backgroundColor: show.isReminderEnabled
            ? DynamicTheme.displayBlack.withOpacity(0.5)
            : DynamicTheme.get(context).secondary100().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
        height: height,
        iconPath: show.isReminderEnabled
            ? Assets.iconCheckMedium
            : Assets.iconNotification,
        iconSize: ComponentSize.smaller.r,
        margin: EdgeInsets.all(ComponentInset.small.r),
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.r),
        text: show.isReminderEnabled
            ? LocaleResources.of(context).scheduled
            : LocaleResources.of(context).remindMe,
        textStyle: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).white()),
        onPressed: () => onReminderButtonTap(show));
  }

  Widget _buildFooter(BuildContext context) {
    final height = ComponentSize.large.h;
    return Container(
        height: height,
        padding: EdgeInsets.only(
            left: ComponentInset.normal.w, right: ComponentInset.small.w),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          /// ARTIST PHOTO
          _buildArtistPhoto(context),
          SizedBox(width: ComponentInset.small.w),

          /// SHOW TITLE & ARTIST NAME
          Expanded(child: _buildTitleAndSubtitle(context)),

          /// SHOW OPTIONS
          _buildOptionsButton(context)
        ]));
  }

  Widget _buildArtistPhoto(BuildContext context) {
    return Photo.artist(
      show.artist.thumbnail,
      options: PhotoOptions(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTitleAndSubtitle(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// SHOW TITLE
          Text(show.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldBody
                  .copyWith(color: DynamicTheme.get(context).white())),

          /// ARTIST NAME
          Text(show.artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.heading6
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ]);
  }

  Widget _buildOptionsButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.small.r,
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: () => onOptionsButtonTap(show));
  }
}
