import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastDetailArgs {
  PodcastDetailArgs({
    required this.id,
    this.title,
    this.thumbnail,
  });

  final String id;
  final String? title;
  final String? thumbnail;
}

class PodcastDetailModel with ChangeNotifier, ItemListModel<PodcastEpisode> {
  //=
  final String _receivedPodcastId;
  final String? _receivedPodcastTitle;
  final String? _receivedPodcastThumbnail;

  late final StreamSubscription _eventsSubscription;

  PodcastDetailModel({
    required PodcastDetailArgs args,
  })  : _receivedPodcastId = args.id,
        _receivedPodcastTitle = args.title,
        _receivedPodcastThumbnail = args.thumbnail {
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<Podcast>>? _podcastOp;
  Result<Podcast>? _podcastResult;

  String? _episodeSearchQuery;
  PodcastEpisodeFilter _episodeFilter = PodcastEpisodeFilter();

  async.CancelableOperation<Result<ListPage<PodcastEpisode>>>?
      _podcastEpisodesOp;
  late final PagingController<int, PodcastEpisode> _podcastEpisodesController;

  void init() {
    _podcastEpisodesController = PagingController(firstPageKey: 1);

    _podcastEpisodesController.addPageRequestListener((pageKey) {
      _fetchPodcastEpisodes(pageKey);
    });

    fetchPodcast();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();

    _podcastOp?.cancel();
    _podcastEpisodesOp?.cancel();
    _podcastEpisodesController.dispose();
    super.dispose();
  }

  Result<Podcast>? get podcastResult => _podcastResult;

  Podcast? get detailedPodcast => _podcastResult?.peek();

  List<PodcastCategory>? get podcastCategories => detailedPodcast?.categories;

  List<Feed>? get podcastFeeds => detailedPodcast?.feeds;

  bool get isPodcastLiked => detailedPodcast?.liked ?? false;

  List<Artist>? get podcastArtists => detailedPodcast?.artists;

  String? get podcastDescription => detailedPodcast?.description;

  int get podcastLikeCount => detailedPodcast?.likes ?? 0;

  String? get podcastPhotoPath =>
      detailedPodcast?.thumbnail ?? _receivedPodcastThumbnail;

  String? get podcastShareableLink => detailedPodcast?.shareableLink;

  String? get podcastTitle => detailedPodcast?.title ?? _receivedPodcastTitle;

  /*
   * Podcast Episode: Search Query
   */

  String? get episodeSearchQuery => _episodeSearchQuery;

  void updateSearchQuery(String text) {
    if (_episodeSearchQuery != text) {
      _episodeSearchQuery = text;
      _podcastEpisodesController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_episodeSearchQuery != null) {
      _episodeSearchQuery = null;
      _podcastEpisodesController.refresh();
      notifyListeners();
    }
  }

  /*
   * Podcast Episode Filter
   */

  PodcastEpisodeFilter get episodeFilter => _episodeFilter;

  bool get isEpisodeFilterApplied => !_episodeFilter.isDefault;

  void setEpisodeFilter(PodcastEpisodeFilter episodeFilter) {
    _episodeFilter = episodeFilter;
    _podcastEpisodesController.refresh();
    notifyListeners();
  }

  void resetDownloadedOnly() {
    setEpisodeFilter(episodeFilter.copyWith(downloadedOnly: false));
  }

  void resetUnplayedOnly() {
    setEpisodeFilter(episodeFilter.copyWith(unplayedOnly: false));
  }

  void resetSortOrder() {
    setEpisodeFilter(episodeFilter.copyWith(
      sortOrder: PodcastEpisodeDateSortOrder.newestToOldest,
    ));
  }

  /*
   * API: Podcast
   */

  Future<void> fetchPodcast() async {
    try {
      // Cancel current operation (if any)
      _podcastOp?.cancel();

      if (_podcastResult != null) {
        _podcastResult = null;
        notifyListeners();
      }

      // Create Request
      final request = PodcastRequest(id: _receivedPodcastId);
      _podcastOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcast(request),
      );

      // Listen for result
      _podcastResult = await _podcastOp?.value;
    } catch (error) {
      _podcastResult = Result.error("Error: $error");
    }

    notifyListeners();
  }

  /*
   * API: Podcast Episode List
   */

  Future<void> _fetchPodcastEpisodes(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _podcastEpisodesOp?.cancel();

      // Create Request
      final request = PodcastEpisodesRequest(
        podcastId: _receivedPodcastId,
        page: pageKey,
        query: _episodeSearchQuery,
        filter: _episodeFilter,
      );
      _podcastEpisodesOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.fetchPodcastEpisodes(request),
        onCancel: () {
          _podcastEpisodesController.error = "Cancelled.";
        },
      );

      // Listen for result
      _podcastEpisodesOp?.value.then((result) {
        if (!result.isSuccess()) {
          _podcastEpisodesController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount =
            _podcastEpisodesController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _podcastEpisodesController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _podcastEpisodesController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _podcastEpisodesController.error = error;
    }
  }

  /*
   * ItemListModel<PodcastEpisode>
   */

  @override
  PagingController<int, PodcastEpisode> controller() =>
      _podcastEpisodesController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _podcastOp?.cancel();
    _podcastEpisodesOp?.cancel();

    if (isForceRefresh) {
      fetchPodcast();
    }

    if (resetPageKey) {
      _podcastEpisodesController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _podcastEpisodesController.retryLastFailedRequest();
    }
  }

  /*
   * API: Podcast: Like
   */

  async.CancelableOperation<Result<PodcastLikeStatus>>? _toggleLikePodcastOp;

  Future<Result<PodcastLikeStatus>> toggleLikePodcast() async {
    final podcast = detailedPodcast;
    if (podcast == null) {
      return Result.error("Something went wrong");
    }

    try {
      // Cancel current operation (if any)
      _toggleLikePodcastOp?.cancel();

      // Create Request
      final request =
          UpdatePodcastLikeRequest(podcastId: podcast.id, like: !podcast.liked);
      final toggleLikePodcastOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().podcastsRepository.updatePodcastLike(request),
      );
      _toggleLikePodcastOp = toggleLikePodcastOp;

      // Listen for result
      final result = await toggleLikePodcastOp.value;
      if (result.isSuccess() && !result.isEmpty()) {
        final data = result.data();
        final event = PodcastLikeUpdatedEvent(
          id: data.id,
          liked: data.liked,
          likes: data.likes,
        );
        eventBus.fire(event);

        _podcastResult = Result.success(event.update(podcast));
        notifyListeners();
      }

      return result;
    } catch (error) {
      return Result.error("Error: $error");
    }
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
      if (event is PodcastLikeUpdatedEvent) {
        return _handlePodcastLikeEvent(event);
      }
      if (event is PodcastEpisodeLikeUpdatedEvent) {
        return _handlePodcastEpisodeLikeEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final podcast = detailedPodcast;
    if (podcast == null) return;

    bool updated = false;
    final updatedArtists = <Artist>[];
    for (final artist in podcast.artists) {
      if (artist.id == event.artistId) {
        final updatedArtist = event.update(artist);
        updatedArtists.add(updatedArtist);
        updated = true;
      } else {
        updatedArtists.add(artist);
      }
    }

    if (updated) {
      final updatedPodcast = podcast.copyWith(artists: updatedArtists);
      _podcastResult = Result.success(updatedPodcast);
      notifyListeners();
    }
  }

  void _handlePodcastLikeEvent(PodcastLikeUpdatedEvent event) {
    final podcast = detailedPodcast;
    if (podcast == null || podcast.id != event.id) return;

    final updatedPodcast = event.update(podcast);
    _podcastResult = Result.success(updatedPodcast);
    notifyListeners();
  }

  void _handlePodcastEpisodeLikeEvent(PodcastEpisodeLikeUpdatedEvent event) {
    _podcastEpisodesController.updateItems<PodcastEpisode>((index, item) {
      return event.update(item);
    });
  }
}
