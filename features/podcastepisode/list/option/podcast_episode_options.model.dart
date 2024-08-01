import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class PodcastEpisodeOptionsArgs {
  PodcastEpisodeOptionsArgs({
    required this.episode,
    this.isOnEpisodePage = false,
    this.playbackItem,
  });

  final PodcastEpisode episode;
  final bool isOnEpisodePage;
  final PlaybackItem? playbackItem;
}

class PodcastEpisodeOptionsModel with ChangeNotifier {
  //=

  PodcastEpisode _episode;
  final bool _isOnEpisodePage;
  final PlaybackItem? playbackItem;

  late final StreamSubscription _eventsSubscription;

  PodcastEpisodeOptionsModel({
    required PodcastEpisodeOptionsArgs args,
  })  : _episode = args.episode,
        _isOnEpisodePage = args.isOnEpisodePage,
        playbackItem = args.playbackItem {
    _eventsSubscription = _listenToEvents();
  }

  PodcastEpisode get episode => _episode;

  bool get isEpisodeLiked => _episode.liked;

  bool get canShowViewEpisodeOption => !_isOnEpisodePage;

  bool get canShowReportEpisodeOption => _isOnEpisodePage;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    super.dispose();
  }

  /*
   * EVENT:
   *  PodcastEpisodeLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PodcastEpisodeLikeUpdatedEvent) {
        return _handlePodcastEpisodeLikeEvent(event);
      }
    });
  }

  void _handlePodcastEpisodeLikeEvent(PodcastEpisodeLikeUpdatedEvent event) {
    final episode = this.episode;
    if (episode.id == event.episodeId) {
      _episode = event.update(_episode);
      notifyListeners();
    }
  }
}
