import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class PodcastEpisodeDetailArgs {
  PodcastEpisodeDetailArgs({
    required this.podcastId,
    required this.episodeId,
    this.title,
    this.thumbnail,
    this.parentPagePodcastId,
  });

  PodcastEpisodeDetailArgs.object({
    required PodcastEpisode episode,
    this.parentPagePodcastId,
  })  : podcastId = episode.podcastId,
        episodeId = episode.id,
        title = episode.title,
        thumbnail = episode.thumbnail;

  final String podcastId;
  final String episodeId;
  final String? title;
  final String? thumbnail;
  final String? parentPagePodcastId;
}

class PodcastEpisodeDetailModel with ChangeNotifier {
  //=
  final PodcastEpisodeDetailArgs _episodeArgs;
  final String? parentPagePodcastId;

  late final StreamSubscription _eventsSubscription;

  PodcastEpisodeDetailModel({
    required PodcastEpisodeDetailArgs args,
  })  : _episodeArgs = args,
        parentPagePodcastId = args.parentPagePodcastId {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<PodcastEpisode>>? _episodeDetailOp;
  Result<PodcastEpisode>? _episodeDetailResult;

  void init() {
    fetchEpisodeDetail();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _episodeDetailOp?.cancel();
    super.dispose();
  }

  Result<PodcastEpisode>? get episodeResult => _episodeDetailResult;

  PodcastEpisode? get episode => _episodeDetailResult?.peek();

  String? get episodeDescription => episode?.description;

  List<Feed>? get episodeFeeds => episode?.feeds;

  String? get episodeTitle => episode?.title ?? _episodeArgs.title;

  String? get episodeThumbnail => episode?.thumbnail ?? _episodeArgs.thumbnail;

  List<Artist>? get podcastArtists => episode?.artists;

  /*
   * API: Podcast Episode Detail
   */

  Future<void> fetchEpisodeDetail() async {
    try {
      // Cancel current operation (if any)
      _episodeDetailOp?.cancel();

      if (_episodeDetailResult != null) {
        _episodeDetailResult = null;
        notifyListeners();
      }

      // Create Request
      final request = PodcastEpisodeRequest(
        podcastId: _episodeArgs.podcastId,
        episodeId: _episodeArgs.episodeId,
      );
      _episodeDetailOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcastEpisode(request),
      );

      // Listen for result
      _episodeDetailResult = await _episodeDetailOp?.value;
    } catch (error) {
      _episodeDetailResult = Result.error("Error: $error");
    }

    notifyListeners();
  }

  /*
   * EVENT:
   *  ArtistBlockUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  PodcastLikeUpdatedEvent,
   *  PodcastEpisodeLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
      if (event is PodcastEpisodeLikeUpdatedEvent) {
        return _handlePodcastEpisodeLikeEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final episode = this.episode;
    if (episode == null) return;

    bool updated = false;
    final updatedArtists = <Artist>[];
    for (final artist in episode.artists) {
      if (artist.id == event.artistId) {
        final updatedArtist = event.update(artist);
        updatedArtists.add(updatedArtist);
        updated = true;
      } else {
        updatedArtists.add(artist);
      }
    }

    if (updated) {
      final updatedEpisode = episode.copyWith(artists: updatedArtists);
      _episodeDetailResult = Result.success(updatedEpisode);
      notifyListeners();
    }
  }

  void _handlePodcastEpisodeLikeEvent(PodcastEpisodeLikeUpdatedEvent event) {
    final episode = this.episode;
    if (episode == null || episode.id != event.episodeId) return;

    final updatedEpisode = event.update(episode);
    _episodeDetailResult = Result.success(updatedEpisode);
    notifyListeners();
  }
}
