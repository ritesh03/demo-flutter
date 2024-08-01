import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/track/track.dart';
import '../../../components/kit/assets.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_radius.dart';
import '../../../components/kit/component_size.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/button.dart';
import '../../../components/widgets/photo/photo.dart';
import '../../../l10n/localizations.dart';
import '../../playback/audio/audio_playback_actions.model.dart';
import '../../profile/subscriptions/subscription_enforcement.dart';
///This is a common widget used in exclusive content and feeds
class SongListWidget extends StatelessWidget {
  String? songImage;
  String? title;
  String? songType;
  bool isFromFeed;
  String? url;
  String? id;
   SongListWidget({Key? key, this.title, this.songImage, this.songType,required this.isFromFeed,this.url,this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isFromFeed?EdgeInsets.zero: EdgeInsets.symmetric(horizontal: ComponentSize.smallest.w),
      child:    Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaleTap(
            onPressed: (){
              Track track =  Track(id: id??"", albumInfo: null, playlistInfo: null, artists: [], duration: Duration(milliseconds: 50000), images: [songImage!], liked: false, likes: 10, name: title??"", url: url??"", shareUrl: '');
              locator<AudioPlaybackActionsModel>().playTrack(track);
            },
            child: Row(
              children: [
                Expanded(
                  child: Container(
                      height: ComponentSize.large.r,
                      color: Colors.transparent,
                      child: Row(children: [
                        _TrackPhoto(songImage: songImage,),
                        SizedBox(width: ComponentInset.small.w),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children:  [
                                _TrackTitle(text:title ?? ""),
                                _TrackSubtitle(text: songType?? ""),
                              ]),
                        ),
                      ])),
                ),

                _TrackOptionsButton(
                  onTap: () {

                  },
                )
              ],
            ),
          ),
        ],
      )
    );



  }
}

class _TrackPhoto extends StatelessWidget {
 String? songImage;
   _TrackPhoto({
    Key? key,  this.songImage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Photo.track(
     songImage ?? "",
      options: PhotoOptions(
          width: ComponentSize.large.h,
          height: ComponentSize.large.w,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }
}
class _TrackTitle extends StatelessWidget {
  const _TrackTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smaller.r,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading5.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }
}

class _TrackSubtitle extends StatelessWidget {
  const _TrackSubtitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.smallest.r,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading6
              .copyWith(color: DynamicTheme.get(context).neutral10())),
    );
  }
}

class _TrackOptionsButton extends StatelessWidget {
  const _TrackOptionsButton({
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