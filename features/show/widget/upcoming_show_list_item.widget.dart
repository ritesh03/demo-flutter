import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/show/options/show_options.bottomsheet.dart';
import 'package:kwotmusic/features/show/options/show_options.model.dart';

class UpcomingShowListItem extends StatelessWidget {
  const UpcomingShowListItem({
    Key? key,
    required this.show,
    required this.onTap,
  }) : super(key: key);

  final Show show;
  final Function(Show show) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(show),
        child: Container(

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(context),
                  _buildFooter(context),
                ])));
  }

  Widget _buildThumbnail(BuildContext context) {
    // Design aspect ratio is 268 x 168 (1.59)
    return AspectRatio(
        aspectRatio: 1.59,
        child: Photo.show(
          show.thumbnail,
          options: PhotoOptions(
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
        ));
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ComponentInset.small.h),
      child: Row(children: [
        /// ARTIST PHOTO
        Photo.artist(
          show.artist.thumbnail,
          options: PhotoOptions(
              width: ComponentSize.small.r,
              height: ComponentSize.small.r,
              shape: BoxShape.circle),
        ),
        SizedBox(width: ComponentInset.small.w),

        /// SHOW TITLE & ARTIST NAME
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// SHOW TITLE
                Text(show.title,
                    style: TextStyles.boldBody
                        .copyWith(color: DynamicTheme.get(context).white()),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),

                /// ARTIST NAME
                Text(show.artist.name,
                    style: TextStyles.heading6
                        .copyWith(color: DynamicTheme.get(context).neutral10()),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ]),
        ),

        /// SHOW OPTIONS
        _buildOptionsButton(context)
      ]),
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.small.r,
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: () => _onOptionsTap(context));
  }

  void _onOptionsTap(BuildContext context) {
    final args = ShowOptionsArgs(show: show);
    ShowOptionsBottomSheet.show(context, args: args);
  }
}
