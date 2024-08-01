import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'skit_page_interface.dart';

class SkitDetailArgs {
  SkitDetailArgs({
    required this.id,
    this.title,
    this.thumbnail,
  });

  final String id;
  final String? title;
  final String? thumbnail;
}

class SkitDetailModel with ChangeNotifier {
  //=
  final String _receivedSkitId;
  final String? _receivedSkitTitle;
  final String? _receivedSkitThumbnail;
  String? _subtitleText;

  late final StreamSubscription _eventsSubscription;

  SkitPageInterface? _pageInterface;

  SkitPageInterface? get pageInterface => _pageInterface;

  SkitDetailModel({
    required SkitDetailArgs args,
  })  : _receivedSkitId = args.id,
        _receivedSkitTitle = args.title,
        _receivedSkitThumbnail = args.thumbnail {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<Skit>>? _skitOp;
  Result<Skit>? _skitResult;

  Function(Skit skit)? onSkitAvailable;

  void init({required Function(Skit skit) onSkitAvailable}) {
    this.onSkitAvailable = onSkitAvailable;
    fetchSkit();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _pageInterface?.dispose();

    _skitOp?.cancel();
    super.dispose();
  }

  Result<Skit>? get skitResult => _skitResult;

  Skit? get skit => _skitResult?.peek();

  String? get title => skit?.title ?? _receivedSkitTitle;

  String? get subtitle => _subtitleText;

  String? get thumbnail => skit?.thumbnail ?? _receivedSkitThumbnail;

  void updateSubtitle(BuildContext context) {
    final skit = this.skit;
    if (skit == null) return;

    final localization = LocaleResources.of(context);

    /// How many views? e.g. 5.7k views
    final viewsText =
        localization.integerViewCountFormat(skit.views, skit.views.prettyCount);

    /// When did it start? e.g. 4 minutes ago
    final createdAt = skit.createdAt;
    final dateTimeText = timeago.format(createdAt);

    _subtitleText = "$viewsText · $dateTimeText";
    pageInterface?.updateSubtitle(subtitle);
  }

  /*
   * API: SKIT
   */

  Future<void> fetchSkit() async {
    try {
      // Cancel current operation (if any)
      _skitOp?.cancel();

      if (_skitResult != null) {
        _skitResult = null;
        notifyListeners();
      }

      // Create Request
      final request = SkitRequest(id: _receivedSkitId);
      _skitOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().skitsRepository.fetchSkit(request),
      );

      // Listen for result
      _skitResult = await _skitOp?.value;
      print(_skitResult);
    } catch (error) {
      _skitResult = Result.error("Error: $error");
    }

    final skit = this.skit;
    if (skit != null) {
      _pageInterface = SkitPageInterface(skit: skit);
      onSkitAvailable?.call(skit);
    }
    notifyListeners();
  }

  /*
   * EVENT:
   *  ArtistBlockUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  SkitLikeUpdatedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
      if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final skit = this.skit;
    if (skit == null || skit.artist.id != event.artistId) return;

    final updatedArtist = event.update(skit.artist);
    final updatedSkit = skit.copyWith(artist: updatedArtist);
    _skitResult = Result.success(updatedSkit);
    notifyListeners();
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    final skit = this.skit;
    if (skit == null || skit.id != event.skitId) return;

    _skitResult = Result.success(event.update(skit));
    notifyListeners();
  }
}
