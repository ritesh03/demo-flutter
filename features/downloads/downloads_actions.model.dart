import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:rxdart/rxdart.dart';

class DownloadActionsModel {
  late final _downloadManager = locator<KwotData>().downloadManager;

  ValueStream<Map<String, TrackDownload>> get downloadsStream =>
      _downloadManager.getDownloadsStream();

  Future<Result> startTrackDownload(Track track) {
    final request = StartTrackDownloadRequest(track: track);
    return _downloadManager.startTrackDownload(request);
  }

  Future<Result> pauseTrackDownload(String trackId) {
    final request = PauseTrackDownloadRequest(id: trackId);
    return _downloadManager.pauseTrackDownload(request);
  }

  Future<Result> resumeTrackDownload(String trackId) {
    final request = ResumeTrackDownloadRequest(id: trackId);
    return _downloadManager.resumeTrackDownload(request);
  }

  // Future<Result> cancelTrackDownload(String trackId) {
  //   final request = CancelTrackDownloadRequest(id: trackId);
  //   return _downloadManager.cancelTrackDownload(request);
  // }

  Future<Result> cancelAllTrackDownloads() {
    return _downloadManager.cancelAllTrackDownloads();
  }

  Future<Result> retryTrackDownload(String trackId) {
    final request = RetryTrackDownloadRequest(id: trackId);
    return _downloadManager.retryTrackDownload(request);
  }

  Future<Result> deleteTrackDownload(String trackId) async {
    final request = DeleteTrackDownloadRequest(id: trackId);
    final result = await _downloadManager.deleteTrackDownload(request);
    if (result.isSuccess()) {
      eventBus.fire(TrackDownloadDeletedEvent(id: trackId));
    }

    return result;
  }
}
