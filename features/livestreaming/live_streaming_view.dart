import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../components/kit/assets.dart';
import '../../components/kit/component_inset.dart';
import '../../components/kit/component_size.dart';
import '../../components/kit/textstyles.dart';
import '../../components/kit/theme/dynamic_theme.dart';
import '../../components/widgets/button.dart';
import '../../components/widgets/photo/photo.dart';
import '../../components/widgets/photo/svg_asset_photo.dart';
import '../../navigation/dashboard_navigation.dart';
import '../artist/fanclubviews/commentbottomsheet/open_comment_bottom_sheet.dart';
import 'package:http/http.dart' as http;

class LiveStreamingView extends StatefulWidget {
  String showTitle;
  String artistImage;
  String channelName;
  String serverUrl;
  String rtcToken;

  LiveStreamingView(
      {Key? key,
      required this.showTitle,
      required this.artistImage,
      required this.channelName,
      required this.serverUrl,required this.rtcToken})
      : super(key: key);
  @override
  State<LiveStreamingView> createState() => _LiveStreamingViewState();
}

class _LiveStreamingViewState extends State<LiveStreamingView> {

  int uid = 0; // uid of the local user
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine;
  String message = "";
  Timer? t; // Agora engine instance
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    setupVideoSDKEngine().then((value) {
        join();
    });
    Future.delayed(const Duration(minutes: 10), () {
      leave();
    });
    setState(() {
      t?.cancel();
      t = Timer(
        const Duration(seconds: 5),
        () => setState(() => t = null),
      );
    });
    super.initState();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DynamicTheme.get(context).neutral60(),
            body: SafeArea(
              child: Stack(
          children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    t?.cancel();
                    t = Timer(
                      const Duration(seconds: 5),
                      () => setState(() => t = null),
                    );
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: Center(child: _videoPanel()),
                ),
              ),
              Positioned(left: 0, top: 0, child: _buildAppBar()),
              Positioned(right: 0, bottom: 0, child: _buildSideBarOptions()),
          ],
        ),
            )),
    );

  }

  Widget _videoPanel() {
    if (!_isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else {
      // Show remote video
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      } else {
        return  Text(
          message,
          textAlign: TextAlign.center,
        );
      }
    }
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
     await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
        const RtcEngineContext(appId: "b8d6d3eb2f1444f2b0bec339e82ff50c"));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
            message = "Waiting for a host to join";
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
            message = "Host joined the channel";
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
            message = "Host leave the channel";
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {

          setState(() {
           agoraEngine.renewToken(token);
          });
        },
        onConnectionLost: (RtcConnection connection) {
            showMessage('connecting lost');
            setState(() {
              message = "Connection lost...";
            });

        },
      ),
    );
  }

  void join() async {
    // Set channel options

    ChannelMediaOptions options;
    options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    // Set channel profile and client role
    await agoraEngine.joinChannel(
      token: widget.rtcToken,
      channelId: widget.channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
      message = "";
    });
    agoraEngine.leaveChannel();
  }

  _buildAppBar() {
    return AnimatedOpacity(
        opacity: t != null ? 1 : 0.0,
        duration: const Duration(seconds: 2),
        child: t != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AppIconButton(
                      width: ComponentSize.large.r,
                      height: ComponentSize.large.r,
                      assetColor: DynamicTheme.get(context).white(),
                      assetPath: Assets.iconArrowLeft,
                      padding: EdgeInsets.all(ComponentInset.small.r),
                      onPressed: () {
                        DashboardNavigation.pop(context);
                        leave();
                      }),
                  SvgAssetPhoto(Assets.liveShowIcon,
                      width: 19.w,
                      height: 15.h,
                      color: DynamicTheme.get(context).white()),
                  SizedBox(
                    width: 14.w,
                  ),
                  _BuildTitle(text: widget.showTitle)
                ],
              )
            : SizedBox());
  }

  _buildSideBarOptions() {
    return Padding(
      padding: EdgeInsets.only(
          right: ComponentInset.small.w, bottom: ComponentInset.small.h),
      child: AnimatedOpacity(
        opacity: t != null ? 1 : 0.0,
        duration: const Duration(seconds: 2),
        child: t != null
            ? Column(
                children: <Widget>[
                  Photo.any(
                    widget.artistImage,
                    options: PhotoOptions(
                      height: 32.r,
                      width: 32.r,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    height: ComponentSize.small8.h,
                  ),
                  /*_buildCustomWidget(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 15.h,
                            ),
                            SvgAssetPhoto(Assets.whiteHeartIcon,
                                width: 19.w,
                                height: 18.h,
                                color: DynamicTheme.get(context).white()),
                            SizedBox(
                              height: 8.h,
                            ),
                            const _BuildLikeCount(text: "122"),
                            SizedBox(
                              height: 8.h,
                            ),
                          ],
                        ),
                      ),
                      onTapItem: () {
                        print(
                            "On tap like icon---------------------------------------------------------------");
                      }),*/
                  /* SizedBox(
              height: ComponentSize.small8.h,
            ),
            _buildCustomWidget(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Center(
                    child: SvgAssetPhoto(Assets.blackKwotIcon,
                        width: 20.w,
                        height: 19.h,
                        color: Colors.black),
                  ),
                ),
                onTapItem: () {}),*/
                  /*SizedBox(
                    height: ComponentSize.small8.h,
                  ),*/
                  _buildCustomWidget(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        child: Center(
                          child: SvgAssetPhoto(Assets.dislikeIcon,
                              width: 20.w,
                              height: 19.h,
                              color: DynamicTheme.get(context).white()),
                        ),
                      ),
                      onTapItem: () {
                        print(
                            "On tap  dislike ===================================================================");
                      }),
                  SizedBox(
                    height: ComponentSize.small8.h,
                  ),
                  _buildCustomWidget(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        child: Center(
                          child: SvgAssetPhoto(
                            Assets.commentIcon,
                            width: 21.w,
                            height: 21.h,
                          ),
                        ),
                      ),
                      onTapItem: () {
                        OpenCommentBottomSheet.show(context);
                      }),
                  SizedBox(
                    height: 48,
                  ),
                  /*SizedBox(
              height: ComponentSize.small8.h,
            ),
            _buildCustomWidget(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Center(
                    child: SvgAssetPhoto(Assets.verticalOptions,
                        width: 6.w,
                        height: 19.h,
                        color: DynamicTheme.get(context).white()),
                  ),
                ),
                onTapItem: () {}),*/
                ],
              )
            : SizedBox(),
      ),
    );
  }

  _buildCustomWidget({required Widget child, required VoidCallback onTapItem}) {
    return GestureDetector(
      onTap: onTapItem,
      child: Container(
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).black().withOpacity(0.3),
            borderRadius: BorderRadius.circular(ComponentSize.small8.r)),
        child: child,
      ),
    );
  }
}

class _BuildTitle extends StatelessWidget {
  const _BuildTitle({
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
          style: TextStyles.boldHeading8.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }
}

class _BuildLikeCount extends StatelessWidget {
  const _BuildLikeCount({
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
          style: TextStyles.boldCaption.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }
}
