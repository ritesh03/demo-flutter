import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'show_page_interface.dart';

class ShowDetailArgs {
  ShowDetailArgs({
    required this.id,
    this.title,
    this.thumbnail,
  });

  final String id;
  final String? title;
  final String? thumbnail;
}

class ShowDetailModel with ChangeNotifier {
  //=
  final String _receivedShowId;
  final String? _receivedShowTitle;
  final String? _receivedShowThumbnail;
  String? _subtitleText;

  late final StreamSubscription _eventsSubscription;

  ShowPageInterface? _pageInterface;

  ShowPageInterface? get pageInterface => _pageInterface;

  ShowDetailModel({
    required ShowDetailArgs args,
  })  : _receivedShowId = args.id,
        _receivedShowTitle = args.title,
        _receivedShowThumbnail = args.thumbnail {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<Show>>? _showOp;
  Result<Show>? _showResult;

  Function(Show show)? onShowAvailable;

  void init({required Function(Show show) onShowAvailable}) {
    this.onShowAvailable = onShowAvailable;
    fetchShow();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _pageInterface?.dispose();

    _showOp?.cancel();
    super.dispose();
  }

  Result<Show>? get showResult => _showResult;

  Show? get show => _showResult?.peek();

  String? get title => show?.title ?? _receivedShowTitle;

  String? get subtitle => _subtitleText;

  String? get thumbnail => show?.thumbnail ?? _receivedShowThumbnail;

  void updateSubtitle(BuildContext context) {
    final show = this.show;
    if (show == null) return;

    final localization = LocaleResources.of(context);

    /// How many views? e.g. 5.7k views
    final viewsText =
        localization.integerViewCountFormat(show.views, show.views.prettyCount);

    /// When did/will it start? e.g. 4 minutes ago
    String dateTimeText = "";

    final formattedStartDate = show.startDateTime.toDefaultDateFormat();
    final formattedStartTime = show.startDateTime.toDefaultTimeFormat();

    if (show.hasNotStarted) {
      final difference = DateTime.now().difference(show.startDateTime);
      if (difference.inHours > 24) {
        dateTimeText = localization.scheduledOnDateFormat(formattedStartDate);
      }
      dateTimeText = localization.startsAtTimeFormat(formattedStartTime);
    } else if (show.isStreamingNow) {
      final timeAgoText = timeago.format(show.startDateTime);
      dateTimeText = localization.startedTimeAgoFormat(timeAgoText);
    } else if (show.wasLiveStream) {
      final endDateTime = show.startDateTime.add(show.totalDuration!);
      dateTimeText = timeago.format(endDateTime);
    } else {
      dateTimeText = timeago.format(show.startDateTime);
    }

    final subtitle = "$viewsText · $dateTimeText";
    _subtitleText = subtitle;
    pageInterface?.updateSubtitle(subtitle);
  }

  /*
   * API: SHOW
   */

  Future<void> fetchShow() async {
    try {
      // Cancel current operation (if any)
      _showOp?.cancel();

      if (_showResult != null) {
        _showResult = null;
        notifyListeners();
      }

      // Create Request
      final request = ShowRequest(id: _receivedShowId);
      _showOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().showsRepository.fetchShow(request),
      );

      // Listen for result
      _showResult = await _showOp?.value;
    } catch (error) {
      _showResult = Result.error("Error: $error");
    }

    final show = this.show;
    if (show != null) {
      _pageInterface = ShowPageInterface(show: show);
      onShowAvailable?.call(show);
    }
    notifyListeners();
  }

  /*
   * EVENT:
   *  ArtistBlockUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  ShowLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
      if (event is ShowLikeUpdatedEvent) {
        return _handleShowLikeEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final show = this.show;
    if (show == null || show.artist.id != event.artistId) return;

    final updatedArtist = event.update(show.artist);
    final updatedShow = show.copyWith(artist: updatedArtist);
    _showResult = Result.success(updatedShow);
    notifyListeners();
  }

  void _handleShowLikeEvent(ShowLikeUpdatedEvent event) {
    final show = this.show;
    if (show == null || show.id != event.showId) return;

    _showResult = Result.success(event.update(show));
    notifyListeners();
  }
}
