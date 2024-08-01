import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/features/downloads/delete/delete_download_confirmation_bottom_sheet.dart';
import 'package:kwotmusic/features/downloads/downloads_actions.model.dart';
import 'package:kwotmusic/features/downloads/widget/download_action_button.widget.dart';
import 'package:kwotmusic/features/downloads/widget/download_progress_text.widget.dart';
import 'package:rxdart/rxdart.dart';

class TrackDownloadStatusWidget extends StatefulWidget {
  const TrackDownloadStatusWidget({
    Key? key,
    required this.track,
  }) : super(key: key);

  final Track track;

  @override
  State<TrackDownloadStatusWidget> createState() =>
      _TrackDownloadStatusWidgetState();
}

class _TrackDownloadStatusWidgetState extends State<TrackDownloadStatusWidget> {
  late TrackDownload _trackDownload;
  late StreamSubscription _trackDownloadSubscription;

  DownloadActionsModel get _downloadActionsModel =>
      locator<DownloadActionsModel>();

  ValueStream<Map<String, TrackDownload>> get _downloadsStream =>
      _downloadActionsModel.downloadsStream;

  @override
  void initState() {
    super.initState();

    _trackDownload = TrackDownload.ofUnknownStatus(id: widget.track.id);

    _trackDownloadSubscription =
        _downloadsStream.listen(_onDownloadsMapUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final status = _trackDownload.status;
    final progress = _trackDownload.progress;
    final textColor = DynamicTheme.get(context).neutral10();

    switch (status) {
      case TrackDownloadStatus.unknown:
      case TrackDownloadStatus.cancelled:
        return const SizedBox.shrink();

      // ENQUEUED
      case TrackDownloadStatus.enqueued:
        return Row(children: [
          DownloadActionButton(iconPath: Assets.iconPause, onTap: _onPauseTap),
          DownloadActionButton(iconPath: Assets.iconCross, onTap: _onCancelTap),
        ]);

      // DOWNLOADING
      case TrackDownloadStatus.downloading:
        return Row(children: [
          DownloadProgressText(progress: progress, textColor: textColor),
          SizedBox(width: ComponentInset.small.r),
          DownloadActionButton(iconPath: Assets.iconPause, onTap: _onPauseTap),
          DownloadActionButton(iconPath: Assets.iconCross, onTap: _onCancelTap),
        ]);

      // DOWNLOADED
      case TrackDownloadStatus.downloaded:
        return Row(children: [
          DownloadActionButton(
              iconPath: Assets.iconDelete, onTap: _onDeleteTap),
        ]);

      // FAILED
      case TrackDownloadStatus.failed:
        return Row(children: [
          DownloadActionButton(
              iconPath: Assets.iconResetBold, onTap: _onRetryTap),
          DownloadActionButton(iconPath: Assets.iconCross, onTap: _onCancelTap),
        ]);

      // PAUSED
      case TrackDownloadStatus.paused:
        return Row(children: [
          DownloadProgressText(progress: progress, textColor: textColor),
          SizedBox(width: ComponentInset.small.r),
          DownloadActionButton(iconPath: Assets.iconPlay, onTap: _onResumeTap),
          DownloadActionButton(iconPath: Assets.iconCross, onTap: _onCancelTap),
        ]);
    }
  }

  @override
  void didUpdateWidget(covariant TrackDownloadStatusWidget oldWidget) {
    if (oldWidget.track.id != widget.track.id) {
      _trackDownload = TrackDownload.ofUnknownStatus(id: widget.track.id);

      final downloadsMap = _downloadsStream.valueOrNull;
      if (downloadsMap != null) {
        _onDownloadsMapUpdated(downloadsMap);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _trackDownloadSubscription.cancel();
    super.dispose();
  }

  void _onDownloadsMapUpdated(Map<String, TrackDownload?> downloadsMap) {
    final updatedTrackDownload = downloadsMap[widget.track.id];
    if (updatedTrackDownload == null) {
      if (_trackDownload.hasUnknownStatus) return;
      setState(() {
        _trackDownload = TrackDownload.ofUnknownStatus(id: widget.track.id);
      });
    } else if (updatedTrackDownload != _trackDownload) {
      setState(() => _trackDownload = updatedTrackDownload);
    }
  }

  void _onCancelTap() {
    _onDeleteTap();
  }

  void _onPauseTap() async {
    showBlockingProgressDialog(context);
    final result =
        await _downloadActionsModel.pauseTrackDownload(widget.track.id);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onResumeTap() async {
    showBlockingProgressDialog(context);
    final result =
        await _downloadActionsModel.resumeTrackDownload(widget.track.id);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onRetryTap() async {
    showBlockingProgressDialog(context);
    final result =
        await _downloadActionsModel.retryTrackDownload(widget.track.id);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }

  void _onDeleteTap() async {
    bool? shouldDelete =
        await DeleteDownloadConfirmationBottomSheet.show(context);
    if (!mounted) return;
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    showBlockingProgressDialog(context);
    final result =
        await _downloadActionsModel.deleteTrackDownload(widget.track.id);

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
    }
  }
}
