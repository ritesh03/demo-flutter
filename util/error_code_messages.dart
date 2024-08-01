import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/l10n/localizations.dart';

String getErrorMessageFromErrorCode(BuildContext context, int errorCode) {
  switch (errorCode) {
    case ErrorCodes.queueUpdateFailedWhenDownloadsArePlaying:
      return LocaleResources.of(context)
          .errorQueueUpdateFailedWhenDownloadsArePlaying;
    case ErrorCodes.queueUpdateFailedWhenRadioStationIsPlaying:
      return LocaleResources.of(context)
          .errorQueueUpdateFailedWhenRadioStationIsPlaying;
    case ErrorCodes.playlistUpdateFailedWhenTrackExists:
      return LocaleResources.of(context)
          .errorPlaylistUpdateFailedWhenTrackExists;
    default:
      return LocaleResources.of(context)
          .errorUnexpectedErrorOccurred;
  }
}
