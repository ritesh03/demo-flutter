import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/features/downloads/downloads_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'track_download_status.widget.dart';

class TrackDownloadOptionWidget extends StatefulWidget {
  const TrackDownloadOptionWidget({
    Key? key,
    required this.margin,
    required this.track,
  }) : super(key: key);

  final EdgeInsets margin;
  final Track track;

  @override
  State<TrackDownloadOptionWidget> createState() =>
      _TrackDownloadOptionWidgetState();
}

class _TrackDownloadOptionWidgetState extends State<TrackDownloadOptionWidget> {
  late TrackDownload _trackDownload;
  late StreamSubscription _trackDownloadSubscription;

  DownloadActionsModel get _downloadActionsModel =>
      locator<DownloadActionsModel>();

  Stream<Map<String, TrackDownload>> get downloadsStream =>
      _downloadActionsModel.downloadsStream;

  @override
  void initState() {
    super.initState();

    _trackDownload = TrackDownload.ofUnknownStatus(id: widget.track.id);

    _trackDownloadSubscription = downloadsStream.listen((downloadsMap) {
      final updatedTrackDownload = downloadsMap[_trackDownload.id];
      if (updatedTrackDownload == null) {
        if (_trackDownload.hasUnknownStatus) return;
        setState(() {
          _trackDownload = TrackDownload.ofUnknownStatus(id: widget.track.id);
        });
      } else if (updatedTrackDownload.status != _trackDownload.status) {
        setState(() => _trackDownload = updatedTrackDownload);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = _trackDownload.status;
    final textColor = DynamicTheme.get(context).neutral10();

    final text = _obtainText(status);
    if (text == null) {
      return const SizedBox.shrink();
    }

    return BottomSheetDiscouragedOption(
        iconPath: Assets.iconDownload,
        margin: widget.margin,
        textColor: textColor,
        text: text,
        trailing: TrackDownloadStatusWidget(track: widget.track));
  }

  @override
  void dispose() {
    _trackDownloadSubscription.cancel();
    super.dispose();
  }

  String? _obtainText(TrackDownloadStatus status) {
    switch (status) {
      case TrackDownloadStatus.unknown:
      case TrackDownloadStatus.cancelled:
        return null;
      case TrackDownloadStatus.enqueued:
        return LocaleResources.of(context).downloadPending;
      case TrackDownloadStatus.downloading:
        return LocaleResources.of(context).downloading;
      case TrackDownloadStatus.downloaded:
        return LocaleResources.of(context).downloaded;
      case TrackDownloadStatus.failed:
        return LocaleResources.of(context).downloadFailed;
      case TrackDownloadStatus.paused:
        return LocaleResources.of(context).downloadPaused;
    }
  }
}
