import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class ReportContentArgs {
  ReportContentArgs({
    required this.content,
  });

  final ReportableContent content;
}

class ReportableContent {
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnail;
  final ReportTarget target;

  ReportableContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.target,
  });

  factory ReportableContent.fromAlbum(Album album) {
    return ReportableContent(
      id: album.id,
      title: album.title,
      subtitle: album.subtitle,
      thumbnail: album.images.isEmpty ? null : album.images.first,
      target: ReportTarget.album,
    );
  }

  factory ReportableContent.fromArtist(Artist artist) {
    return ReportableContent(
      id: artist.id,
      title: artist.name,
      subtitle: null,
      thumbnail: artist.thumbnail,
      target: ReportTarget.artist,
    );
  }

  factory ReportableContent.fromPlaylist(Playlist playlist) {
    return ReportableContent(
      id: playlist.id,
      title: playlist.name,
      subtitle: playlist.owner.name,
      thumbnail: playlist.images.isEmpty ? null : playlist.images.first,
      target: ReportTarget.playlist,
    );
  }

  factory ReportableContent.fromPodcastEpisode(PodcastEpisode episode) {
    return ReportableContent(
      id: episode.id,
      title: episode.title,
      subtitle: episode.subtitle,
      thumbnail: episode.thumbnail,
      target: ReportTarget.podcastEpisode,
    );
  }

  factory ReportableContent.fromRadioStation(RadioStation radioStation) {
    return ReportableContent(
      id: radioStation.id,
      title: radioStation.title,
      subtitle: null,
      thumbnail: radioStation.thumbnail,
      target: ReportTarget.radioStation,
    );
  }

  factory ReportableContent.fromShow(Show show) {
    return ReportableContent(
      id: show.id,
      title: show.title,
      subtitle: show.artist.name,
      thumbnail: show.thumbnail,
      target: ReportTarget.show,
    );
  }

  factory ReportableContent.fromSkit(Skit skit) {
    return ReportableContent(
      id: skit.id,
      title: skit.title,
      subtitle: skit.artist.name,
      thumbnail: skit.thumbnail,
      target: ReportTarget.skit,
    );
  }

  factory ReportableContent.fromTrack(Track track) {
    return ReportableContent(
      id: track.id,
      title: track.name,
      subtitle: track.subtitle,
      thumbnail: track.images.isEmpty ? null : track.images.first,
      target: ReportTarget.track,
    );
  }

  factory ReportableContent.fromUser(User user) {
    return ReportableContent(
        id: user.id,
        title: user.name,
        subtitle: null,
        thumbnail: user.thumbnail,
        target: ReportTarget.user);
  }
}

class ReportContentModel with ChangeNotifier {
  //=

  final ReportableContent content;

  ReportContentModel({
    required ReportContentArgs args,
  }) : content = args.content;

  async.CancelableOperation<Result<List<ReportReason>>>? _reportReasonsOp;
  Result<List<ReportReason>>? reportReasonsResult;

  TextEditingController descriptionInputController = TextEditingController();
  ReportReason? selectedReportReason;

  void init() {
    fetchReportReasons();
  }

  @override
  void dispose() {
    _reportReasonsOp?.cancel();
    _reportReasonsOp = null;

    _reportContentOp?.cancel();
    _reportContentOp = null;
    super.dispose();
  }

  bool get canSendReport {
    return reportReasonsResult != null &&
        reportReasonsResult!.isSuccess() &&
        reportReasonsResult!.data().isNotEmpty;
  }

  Future<void> fetchReportReasons() async {
    try {
      // Cancel current operation (if any)
      _reportReasonsOp?.cancel();

      if (reportReasonsResult != null) {
        reportReasonsResult = null;
        notifyListeners();
      }

      // Create Request
      final request = ReportReasonsRequest(target: content.target);
      _reportReasonsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchReportReasons(request));

      // Wait for result
      reportReasonsResult = await _reportReasonsOp?.value;
    } catch (error) {
      reportReasonsResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  /*
   * Report Reason Input
   */

  String? _reportReasonInputError;

  String? get reportReasonInputError => _reportReasonInputError;

  void onReportReasonInputChanged(String text) {
    _notifyReportReasonInputError(null);
  }

  void _notifyReportReasonInputError(String? error) {
    _reportReasonInputError = error;
    notifyListeners();
  }

  void updateSelectedReportReason(ReportReason reportReason) {
    selectedReportReason = reportReason;
    _notifyReportReasonInputError(null);
  }

  /*
   * Description Input
   */

  String? _descriptionInputError;

  String? get descriptionInputError => _descriptionInputError;

  void onDescriptionInputChanged(String text) {
    _notifyDescriptionInputError(null);
  }

  void _notifyDescriptionInputError(String? error) {
    _descriptionInputError = error;
    notifyListeners();
  }

  /*
   * API: REPORT CONTENT
   */

  async.CancelableOperation<Result>? _reportContentOp;

  Future<Result?> reportContent(BuildContext context) async {
    final localization = LocaleResources.of(context);

    _reportContentOp?.cancel();

    // Validate report-reason
    final reportReason = selectedReportReason;
    String? reportReasonInputError;
    if (reportReason == null) {
      reportReasonInputError = localization.errorReportReasonNotSelected;
    }
    _notifyReportReasonInputError(reportReasonInputError);

    // Validate Description
    final descriptionInput = descriptionInputController.text.trim();
    String? descriptionInputError;
    if (descriptionInput.isEmpty) {
      descriptionInputError = localization.errorEnterReportContentDescription;
    } else if (descriptionInput.length < 20) {
      descriptionInputError =
          localization.errorReportContentDescriptionTooShort;
    }
    _notifyDescriptionInputError(descriptionInputError);

    if (reportReasonInputError != null || descriptionInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Create operation
    final request = ReportContentRequest(
      target: content.target,
      contentId: content.id,
      reasonId: reportReason!.id,
      description: descriptionInput,
    );

    _reportContentOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.reportContent(request));

    // Listen for result
    return await _reportContentOp!.value;
  }
}
