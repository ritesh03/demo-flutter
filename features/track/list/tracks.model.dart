import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'tracks.args.dart';

class TracksModel with ChangeNotifier, ItemListModel<Track> {
  //=
  final Feed<Track>? _initialFeed;
  late TracksFilter filter;

  ItemListViewMode _viewMode = ItemListViewMode.list;

  late final StreamSubscription _eventsSubscription;

  TracksModel({
    required TrackListArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = TracksFilter(
      query: null,
      genres: args.genres ?? [],
      albumId: args.albumId,
      feedId: _initialFeed?.id,
    );
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<Track>>>? _tracksOp;
  late final PagingController<int, Track> _tracksController;

  void init() {
    final initialFeed = _initialFeed;
    if (initialFeed != null) {
      _viewMode = createViewModeFromFeed(initialFeed);
    }

    _tracksController = PagingController<int, Track>(firstPageKey: 1);
    _tracksController.addPageRequestListener((pageKey) {
      _fetchTracks(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _tracksOp?.cancel();
    _tracksController.dispose();
    super.dispose();
  }

  /*
   * Page
   */

  String? get pageTitle {
    if (!canSearchInFeed && filter.hasSearchQuery) {
      return null;
    }

    final feedTitle = _initialFeed?.pageTitle;
    if (feedTitle != null) {
      return feedTitle;
    }

    return null;
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => filter.query;

  void updateSearchQuery(String text) {
    if (appliedSearchQuery != text) {
      filter = filter.copyWithQuery(query: text);
      _tracksController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      _tracksController.refresh();
      notifyListeners();
    }
  }

  /*
   * TRACKS filter
   */

  List<MusicGenre> get selectedGenres => filter.genres.toList();

  bool get filtered => filter.hasGenres;

  void setSelectedGenres(List<MusicGenre> genres) {
    final selectedGenres = filter.genres;
    if (selectedGenres.isEmpty && genres.isEmpty) {
      notifyListeners();
      return;
    }

    filter = filter.copyWithGenres(genres: genres);
    _tracksController.refresh();
    notifyListeners();
  }

  void removeSelectedGenre(MusicGenre genre) {
    final selectedGenres = filter.genres.toList();
    selectedGenres.removeWhere((element) => (element.id == genre.id));
    filter = filter.copyWithGenres(genres: selectedGenres);

    _tracksController.refresh();
    notifyListeners();
  }

  PlayTrackRequest createPlayTrackRequest(Track track) {
    final tracksRequest =
        filter.toRequest(page: 1, canSearchInFeed: canSearchInFeed);

    final albumId = tracksRequest.albumId;
    if (albumId != null) {
      return PlayTrackRequest.album(albumId,
          track: track,
          query: tracksRequest.query,
          genres: tracksRequest.genres);
    }

    final feedId = tracksRequest.feedId;
    if (feedId != null) {
      return PlayTrackRequest.feed(feedId,
          track: track,
          query: tracksRequest.query,
          genres: tracksRequest.genres);
    }

    return PlayTrackRequest(track: track);
  }

  /*
   * View Mode
   */

  ItemListViewMode get viewMode => _viewMode;

  int get viewColumnCount {
    switch (viewMode) {
      case ItemListViewMode.list:
        return 1;
      case ItemListViewMode.grid:
        return 2;
    }
  }

  void showListViewMode() {
    _viewMode = ItemListViewMode.list;
    notifyListeners();
  }

  void showGridViewMode() {
    _viewMode = ItemListViewMode.grid;
    notifyListeners();
  }

  /*
   * API: TRACK List
   */

  Future<void> _fetchTracks(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _tracksOp?.cancel();

      // Create Request
      final request = filter.toRequest(
        page: pageKey,
        canSearchInFeed: canSearchInFeed,
      );
      _tracksOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().tracksRepository.fetchTracks(request),
        onCancel: () {
          _tracksController.error = "Cancelled.";
        },
      );

      // Listen for result
      _tracksOp?.value.then((result) {
        if (!result.isSuccess()) {
          _tracksController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _tracksController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _tracksController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _tracksController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _tracksController.error = error;
    }
  }

  /*
   * ItemListModel<TRACK>
   */

  @override
  PagingController<int, Track> controller() => _tracksController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _tracksOp?.cancel();

    if (resetPageKey) {
      _tracksController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _tracksController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  TrackLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      }
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    _tracksController.updateItems<Track>((index, item) {
      return event.update(item);
    });
  }
}
