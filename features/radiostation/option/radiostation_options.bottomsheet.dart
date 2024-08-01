import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/radiostation/option/radiostation_options.model.dart';
import 'package:kwotmusic/features/radiostation/radio_station_actions.model.dart';
import 'package:kwotmusic/features/radiostation/widget/radio_station_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class RadioStationOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required RadioStation radioStation,
    PlaybackItem? playbackItem,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => ChangeNotifierProvider(
          create: (_) => RadioStationOptionsModel(
                radioStation: radioStation,
                playbackItem: playbackItem,
              ),
          child: const RadioStationOptionsBottomSheet()),
    );
  }

  const RadioStationOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<RadioStationOptionsBottomSheet> createState() =>
      _RadioStationOptionsBottomSheetState();
}

class _RadioStationOptionsBottomSheetState
    extends State<RadioStationOptionsBottomSheet> {
  //=

  RadioStationOptionsModel get radioStationOptionsModel =>
      context.read<RadioStationOptionsModel>();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          _buildCompactPreview(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          _buildLikeTileWidget(),
          SizedBox(height: ComponentInset.small.h),
          BottomSheetTile(
              iconPath: Assets.iconShare,
              text: LocaleResources.of(context).share,
              onTap: _onShareButtonTapped),
          SizedBox(height: ComponentInset.normal.h),
          BottomSheetTile(
              iconPath: Assets.iconReport,
              text: LocaleResources.of(context).report,
              onTap: _onReportButtonTapped),
          SizedBox(height: ComponentInset.normal.h),
          _RemoveFromPlayingQueueOption(onTap: _onRemoveFromQueueButtonTapped),
          SizedBox(height: ComponentInset.normal.h),
        ]));
  }

  Widget _buildCompactPreview() {
    return Selector<RadioStationOptionsModel, RadioStation>(
        selector: (_, model) => model.radioStation,
        builder: (_, radioStation, __) {
          return RadioStationCompactPreview(radioStation: radioStation);
        });
  }

  Widget _buildLikeTileWidget() {
    return Selector<RadioStationOptionsModel, bool>(
        selector: (_, model) => model.liked,
        builder: (_, liked, __) {
          return BottomSheetTile(
              iconPath:
                  liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
              text: liked
                  ? LocaleResources.of(context).unlike
                  : LocaleResources.of(context).like,
              onTap: () => _onLikeButtonTapped(context));
        });
  }

  void _onLikeButtonTapped(BuildContext context) async {
    final radioStation = radioStationOptionsModel.radioStation;

    showBlockingProgressDialog(context);
    final result =
        await locator<RadioStationActionsModel>().toggleLike(radioStation);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }
  }

  void _onShareButtonTapped() async {
    final radioStation = radioStationOptionsModel.radioStation;
    Share.share(radioStation.shareableLink);
  }

  void _onRemoveFromQueueButtonTapped() {
    locator<AudioPlaybackActionsModel>().stopPlayback();
    RootNavigation.pop(context);
  }

  void _onReportButtonTapped() async {
    RootNavigation.popUntilRoot(context);

    final radioStation = radioStationOptionsModel.radioStation;
    final args = ReportContentArgs(
        content: ReportableContent.fromRadioStation(radioStation));
    DashboardNavigation.pushNamed(
      context,
      Routes.reportContent,
      arguments: args,
    );
  }
}

class _RemoveFromPlayingQueueOption extends StatelessWidget {
  const _RemoveFromPlayingQueueOption({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<RadioStationOptionsModel, PlaybackItem?>(
        selector: (_, model) => model.playbackItem,
        builder: (_, playbackItem, __) {
          if (playbackItem == null) return const SizedBox.shrink();
          return BottomSheetDiscouragedOption(
              iconPath: Assets.iconDelete,
              text: LocaleResources.of(context).playingQueueRemoveItem,
              onTap: onTap);
        });
  }
}
