import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_switch_tile.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/components/widgets/chip/chip.widget.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class VideoPlaybackSettingsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required VoidCallback onReportTap,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) {
        return VideoPlaybackSettingsBottomSheet(
          controller: controller,
          selectedVideoTrack:
              videoPlayerManager.selectedVideoTrackNotifier.value,
          availableVideoTracks:
              videoPlayerManager.availableVideoTracksNotifier.value,
          onSelectedVideoTrackChange: (track) {
            videoPlayerManager.selectVideoTrack(track);
            return true;
          },
          isCaptionsOptionEnabled:
              videoPlayerManager.isCaptionsOptionEnabledNotifier.value,
          availableCaptionTracks:
              videoPlayerManager.availableSubtitleTracksNotifier.value,
          onCaptionsOptionChange: (enabled) {
            enabled
                ? videoPlayerManager.enableCaptions()
                : videoPlayerManager.disableCaptions();
            return true;
          },
          isLoopVideoOptionEnabled:
              videoPlayerManager.isLoopVideoOptionEnabledNotifier.value,
          canEnabledLoopVideoOption:
              videoPlayerManager.canChangeLoopVideoOptionNotifier.value,
          onLoopVideoOptionChange: (enabled) {
            enabled
                ? videoPlayerManager.enableLooping()
                : videoPlayerManager.disableLooping();
            return true;
          },
          onReportTap: onReportTap,
        );
      },
    );
  }

  const VideoPlaybackSettingsBottomSheet({
    Key? key,
    required this.controller,
    required this.selectedVideoTrack,
    required this.availableVideoTracks,
    required this.onSelectedVideoTrackChange,
    required this.isCaptionsOptionEnabled,
    required this.availableCaptionTracks,
    required this.onCaptionsOptionChange,
    required this.isLoopVideoOptionEnabled,
    required this.canEnabledLoopVideoOption,
    required this.onLoopVideoOptionChange,
    required this.onReportTap,
  }) : super(key: key);

  final ScrollController controller;
  final VideoPlaybackTrack selectedVideoTrack;
  final List<VideoPlaybackTrack> availableVideoTracks;
  final bool Function(VideoPlaybackTrack track) onSelectedVideoTrackChange;

  final bool isCaptionsOptionEnabled;
  final List<VideoPlaybackSubtitleTrack> availableCaptionTracks;
  final bool Function(bool enabled) onCaptionsOptionChange;

  final bool isLoopVideoOptionEnabled;
  final bool canEnabledLoopVideoOption;
  final bool Function(bool enabled) onLoopVideoOptionChange;

  final VoidCallback onReportTap;

  @override
  State<VideoPlaybackSettingsBottomSheet> createState() =>
      _VideoPlaybackSettingsBottomSheetState();
}

class _VideoPlaybackSettingsBottomSheetState
    extends State<VideoPlaybackSettingsBottomSheet> {
  //=

  late VideoPlaybackTrack _selectedVideoTrack;
  late bool _isCaptionsOptionEnabled;
  late bool _isLoopVideoOptionEnabled;

  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);

  @override
  void initState() {
    super.initState();

    _selectedVideoTrack = widget.selectedVideoTrack;
    _isCaptionsOptionEnabled = widget.isCaptionsOptionEnabled;
    _isLoopVideoOptionEnabled = widget.isLoopVideoOptionEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final tileMargin = horizontalPadding;

    return SingleChildScrollView(
        controller: widget.controller,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.medium.h),

          /// VIDEO TRACKS
          _buildVideoPlaybackTracksSelection(),

          /// CAPTIONS
          _VideoCaptionOption(
              enabled: _isCaptionsOptionEnabled,
              hasCaptions: widget.availableCaptionTracks.isNotEmpty,
              margin: tileMargin,
              onChanged: _onCaptionsOptionTap),
          SizedBox(height: ComponentInset.medium.h),

          /// LOOP VIDEO
          BottomSheetSwitchTile(
              checked: _isLoopVideoOptionEnabled,
              height: ComponentSize.smaller.h,
              enabled: widget.canEnabledLoopVideoOption,
              margin: tileMargin,
              onChanged: (checked) => _onLoopVideoOptionTap(enabled: checked),
              text: LocaleResources.of(context).broadcastLoopLabel),
          SizedBox(height: ComponentInset.medium.h),

          /// REPORT
          BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: widget.onReportTap),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildVideoPlaybackTracksSelection() {
    final tracks = widget.availableVideoTracks;

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: horizontalPadding,
            child: Text(LocaleResources.of(context).videoQuality,
                style: TextStyles.boldBody
                    .copyWith(color: DynamicTheme.get(context).white())),
          ),
          if (tracks.isNotEmpty) SizedBox(height: ComponentInset.small.r),
          tracks.isEmpty
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: horizontalPadding,
                  child: Text(
                      LocaleResources.of(context)
                          .errorBroadcastQualityUnavailable,
                      style: TextStyles.body.copyWith(
                          color: DynamicTheme.get(context).neutral20())))
              : SizedBox(
                  height: ComponentSize.normal.r,
                  child: _VideoQualityItemOptionsList(
                    padding: horizontalPadding,
                    tracks: tracks,
                    selectedTrack: _selectedVideoTrack,
                    onTrackTap: _onVideoPlaybackTrackOptionTap,
                  )),
          SizedBox(height: ComponentInset.medium.h),
        ]);
  }

  void _onVideoPlaybackTrackOptionTap(VideoPlaybackTrack track) {
    _selectedVideoTrack = track;
    final updated = widget.onSelectedVideoTrackChange(track);
    if (updated) {
      setState(() {});
    }
  }

  void _onCaptionsOptionTap(bool enabled) {
    _isCaptionsOptionEnabled = enabled;
    final updated = widget.onCaptionsOptionChange(_isCaptionsOptionEnabled);
    if (updated) {
      setState(() {});
    }
  }

  void _onLoopVideoOptionTap({required bool enabled}) {
    _isLoopVideoOptionEnabled = enabled;
    final updated = widget.onLoopVideoOptionChange(_isLoopVideoOptionEnabled);
    if (updated) {
      setState(() {});
    }
  }
}

class _VideoCaptionOption extends StatelessWidget {
  const _VideoCaptionOption({
    Key? key,
    required this.enabled,
    required this.hasCaptions,
    required this.margin,
    required this.onChanged,
  }) : super(key: key);

  final bool enabled;
  final bool hasCaptions;
  final EdgeInsets margin;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    if (!hasCaptions) {
      return Container(
        width: double.infinity,
        margin: margin,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localization.videoCaptions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldBody
                      .copyWith(color: DynamicTheme.get(context).white())),
              Text(localization.errorBroadcastCaptionsUnavailable,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.body
                      .copyWith(color: DynamicTheme.get(context).neutral20()))
            ]),
      );
    }

    return BottomSheetSwitchTile(
        checked: enabled,
        height: ComponentSize.smaller.h,
        margin: margin,
        onChanged: onChanged,
        text: localization.videoCaptions);
  }
}

class _VideoQualityItemOptionsList extends StatelessWidget {
  const _VideoQualityItemOptionsList({
    Key? key,
    required this.padding,
    required this.tracks,
    required this.selectedTrack,
    required this.onTrackTap,
  }) : super(key: key);

  final EdgeInsets padding;
  final List<VideoPlaybackTrack> tracks;
  final VideoPlaybackTrack selectedTrack;
  final Function(VideoPlaybackTrack) onTrackTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        padding: padding,
        itemBuilder: (_, index) {
          final track = tracks[index];
          final isSelected = (selectedTrack.isAuto && track.isAuto) ||
              (selectedTrack == track);

          return _VideoQualityItemOption(
            videoPlaybackTrack: track,
            isSelected: isSelected,
            onTap: onTrackTap,
          );
        },
        separatorBuilder: (_, __) {
          return SizedBox(width: ComponentInset.small.r);
        });
  }
}

class _VideoQualityItemOption extends StatelessWidget {
  const _VideoQualityItemOption({
    Key? key,
    required this.videoPlaybackTrack,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final VideoPlaybackTrack videoPlaybackTrack;
  final bool isSelected;
  final Function(VideoPlaybackTrack) onTap;

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    final trackName = videoPlaybackTrack.isAuto
        ? LocaleResources.of(context).videoQualityAuto
        : videoPlaybackTrack.name ?? localeResource.videoTrackUnknown;
    return ChipWidget(
      data: videoPlaybackTrack,
      text: trackName,
      selected: isSelected,
      onPressed: onTap,
    );
  }
}
