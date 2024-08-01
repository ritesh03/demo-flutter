import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/report_content.dart';
import 'package:kwotmusic/components/widgets/photo/photo_kind.dart';
import 'package:kwotmusic/l10n/localizations.dart';

extension ReportTargetExt on ReportTarget {
  PhotoKind get photoKind {
    switch (this) {
      case ReportTarget.album:
        return PhotoKind.album;
      case ReportTarget.artist:
        return PhotoKind.artist;
      case ReportTarget.playlist:
        return PhotoKind.playlist;
      case ReportTarget.podcastEpisode:
        return PhotoKind.podcastEpisode;
      case ReportTarget.radioStation:
        return PhotoKind.radioStation;
      case ReportTarget.show:
        return PhotoKind.show;
      case ReportTarget.skit:
        return PhotoKind.skit;
      case ReportTarget.track:
        return PhotoKind.track;
      case ReportTarget.user:
        return PhotoKind.user;
    }
  }

  String getReportTypeText(BuildContext context) {
    final localization = LocaleResources.of(context);
    switch (this) {
      case ReportTarget.album:
        return localization.reportTypeAlbum;
      case ReportTarget.artist:
        return localization.reportTypeArtist;
      case ReportTarget.playlist:
        return localization.reportTypePlaylist;
      case ReportTarget.podcastEpisode:
        return localization.reportTypePodcastEpisode;
      case ReportTarget.radioStation:
        return localization.reportTypeRadioStation;
      case ReportTarget.show:
        return localization.reportTypeShow;
      case ReportTarget.skit:
        return localization.reportTypeSkit;
      case ReportTarget.track:
        return localization.reportTypeTrack;
      case ReportTarget.user:
        return localization.reportTypeUser;
    }
  }
}
