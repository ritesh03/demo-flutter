import 'package:flutter/cupertino.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/track/track.dart';
import 'package:kwotdata/models/videos/video.dart';
import 'package:kwotmusic/components/kit/component_inset.dart';
import 'package:kwotmusic/features/show/detail/show_detail.bottomsheet.dart';
import 'package:kwotmusic/features/show/detail/show_detail.model.dart';
import 'package:kwotmusic/features/videos/detail/video_details_model.dart';
import 'package:kwotmusic/features/videos/detail/videos_detail_bottomsheet.dart';
import '../../../components/kit/assets.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/photo/photo.dart';
import '../../../l10n/localizations.dart';
import '../../../util/date_time_methods.dart';
import '../../playback/audio/audio_playback_actions.model.dart';
import '../../profile/subscriptions/subscription_enforcement.dart';
import '../../skit/detail/skit_detail.bottomsheet.dart';
import '../../skit/detail/skit_detail.model.dart';
///This is a common widget used in exclusive content and feeds
class VideosWidget extends StatelessWidget {

  String? title;

  String? url;

  String? addedAt;

  String? image;

  String id;


  String? duration;

  String? views;
  bool isFromFeed;

  VideosWidget({Key? key,required this.isFromFeed,required this.title,required this.image,required this.duration,required this.addedAt,required this.views, required this.id,required this.url,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isFromFeed? EdgeInsets.zero:EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ScaleTap(
            onPressed: () {
              VideosDetailBottomSheet.showBottomSheet(context,args: VideosDetailArgs(
                id: id,
                url: url!,
                title: title!,
                addedAt: addedAt!,
                duration: duration!,
                image: image!,
                views: views!
              ));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildVideoView(context,image??"",int.parse(duration!)),
                SizedBox(
                  width: ComponentInset.small.w,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                     Container(
                       constraints: BoxConstraints(maxWidth: 180.w),
                       child: Text(
                          title ??"",
                          style: TextStyles.boldHeading5,
                          overflow: TextOverflow.ellipsis, maxLines: 1,
                        ),
                     ),
                    SizedBox(
                      height: ComponentInset.small.h,
                    ),
                    Text(
                      "${views == null ? 0 : DateConvertor.getViews(int.parse(views!))} views · ${addedAt == null ? 0 : DateConvertor.displayTimeAgoFromTimestamp(addedAt!)}",
                      style: TextStyles.lightHeading6.copyWith(
                          color: DynamicTheme.get(context).neutral10()),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                _VideoOptionButton(
                  onTap: () {},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildVideoView(BuildContext context, String videoImage, int? videoDuration) {
  return SizedBox(
    height: 76.h,
    width: 126.w,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          height: 76.h,
          width: 126.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ComponentInset.small.r)),
          child: Photo.skit(videoImage ?? "",
              options: PhotoOptions(
                  borderRadius: BorderRadius.circular(ComponentInset.small.r),
                  fit: BoxFit.cover)),
        ),
        Positioned(
            right: 4.w,
            bottom: 4.h,
            child: Container(
              height: 24.h,
              decoration: BoxDecoration(
                color: DynamicTheme.get(context).black().withOpacity(0.5),
                borderRadius: BorderRadius.circular(ComponentInset.small.r),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
                child: Center(
                    child: Text(
                  DateConvertor.convertTime(
                      videoDuration == null ? 0 : videoDuration),
                  style: TextStyles.heading5,
                )),
              ),
            ))
      ],
    ),
  );
}

class _VideoOptionButton extends StatelessWidget {
  const _VideoOptionButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
        width: 20.w,
        height: 25.h,
        // padding: EdgeInsets.all(ComponentInset.small.r),
        assetPath: Assets.iconOptions,
        assetColor: DynamicTheme.get(context).white(),
        onPressed: onTap);
  }
}
