
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/videos/video.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/features/videos/detail/video_details_model.dart';

import '../../../components/kit/component_inset.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/bottomsheet/material_bottom_sheet.dart';
import '../../../l10n/localizations.dart';
import '../../../navigation/root_navigation.dart';

//import 'package:flick_video_player/flick_video_player.dart';

import 'package:visibility_detector/visibility_detector.dart';

import 'package:timeago/timeago.dart' as timeago;

import '../../playback/audio/audio_playback_actions.model.dart';
import '../../playback/playback.dart';
import '../../playback/video/controls/video_controls_visibility.model.dart';
import '../../playback/video/widget/video_page_top_bar.widget.dart';
import 'controls.dart';

class VideosDetailBottomSheet extends StatefulWidget {
  //=
  static Future showBottomSheet(
      BuildContext context, {
        required VideosDetailArgs args,
      }) {
    return showMaterialBottomSheet<void>(
      context,
      backgroundColor: DynamicTheme.get(context).background(),
      borderRadius: BorderRadius.zero,
      margin: EdgeInsets.zero,
      builder: (context, controller) {
        return MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => VideoControlsVisibilityModel()),
        ],child: VideosDetailBottomSheet(controller: controller, args:args));
      }
    );
  }

   VideosDetailBottomSheet({
    Key? key,
    this.controller,
    required this.args

  }) : super(key: key);

  final ScrollController? controller;
  VideosDetailArgs args;

  @override
  State<VideosDetailBottomSheet> createState() => _VideosDetailBottomSheetState();
}

class _VideosDetailBottomSheetState extends State<VideosDetailBottomSheet> {
  late FlickManager flickManager;
 @override
 void initState() {

   super.initState();

   /// Stop Audio Playback
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     locator<AudioPlaybackActionsModel>().stopAudioPlayback();
   });
   flickManager = FlickManager(
       videoPlayerController: VideoPlayerController.network(
        widget.args.url
       ),
       onVideoEnd: () {

       });


   /// Listen to changes in Video Item
  // videoPlayerManager.videoItemNotifier.addListener(_videoItemListener);
 }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:VisibilityDetector(
          key: ObjectKey(flickManager),
          onVisibilityChanged: (visibility) {
            if (visibility.visibleFraction == 0 && this.mounted) {
              flickManager.flickControlManager?.autoPause();
            } else if (visibility.visibleFraction == 1) {
              flickManager.flickControlManager?.autoResume();
            }
          },
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child:FlickVideoPlayer(
                        flickManager: flickManager,
                        preferredDeviceOrientationFullscreen: [

                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ],
                        flickVideoWithControls: FlickVideoWithControls(
                          videoFit: BoxFit.contain,
                          controls: CustomOrientationControls(),
                        ),
                        flickVideoWithControlsFullscreen: FlickVideoWithControls(
                          videoFit: BoxFit.contain,
                          controls: CustomOrientationControls(),
                        ),
                      )),
                  ),

                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ComponentInset.normal.h),
                          _buildTitle(context, widget.args.title),
                          SizedBox(height: ComponentInset.normal.h),
                          _buildSubtitle(context),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: VideoPageTopBar(onBackTap: () {
                    return RootNavigation.popUntilRoot(context);
                  }))
            ],
          ),
        ),
      ),
    );
  }


 @override
 void dispose() {
   flickManager.dispose();
   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
       overlays: SystemUiOverlay.values);
   SystemChrome.setPreferredOrientations(
       [DeviceOrientation.portraitUp]);
   super.dispose();
 }
 Widget _buildTitle(BuildContext context, title) {
   return Text(title ?? "",
       maxLines: 2,
       overflow: TextOverflow.ellipsis,
       style: TextStyles.boldHeading2
           .copyWith(color: DynamicTheme.get(context).white()));
 }

 Widget _buildSubtitle(BuildContext context) {

   return Text(updateSubtitle(context),
       maxLines: 1,
       overflow: TextOverflow.ellipsis,
       style: TextStyles.body
           .copyWith(color: DynamicTheme.get(context).neutral10()));
 }


 String updateSubtitle(BuildContext context) {
   final localization = LocaleResources.of(context);
   final viewsText =
   localization.integerViewCountFormat(int.parse(widget.args.views), int.parse(widget.args.views).prettyCount);
   /// When did it start? e.g. 4 minutes ago
   final createdAt = DateTime.parse(widget.args.addedAt);
   final dateTimeText = timeago.format(createdAt);
    return "$viewsText · $dateTimeText";
   }


 // void _videoItemListener() {
 //   final videoItem = videoPlayerManager.videoItemNotifier.value;
 //   if (videoItem == null) {
 //     RootNavigation.pop(context);
 //   }
 // }


 }