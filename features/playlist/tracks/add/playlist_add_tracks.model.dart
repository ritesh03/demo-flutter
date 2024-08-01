import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'playlist_add_tracks.args.dart';

enum PlaylistTrackSource { suggested, recentlyPlayed, liked }

class PlaylistAddTracksModel
    with
        ChangeNotifier,
        ItemListModel<Track>,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  final PlaylistAddTracksArgs args;
  PlaylistTrackSource? _selectedTrackSource;

  final _searchInputController = TextEditingController();

  async.CancelableOperation<Result<ListPage<Track>>>? _tracksOp;
  late final PagingController<int, Track> _tracksController;

  late final StreamSubscription _eventsSubscription;

  PlaylistAddTracksModel({
    required this.args,
  }) {
    _selectedTrackSource = PlaylistTrackSource.suggested;
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    _tracksController = PagingController<int, Track>(firstPageKey: 1);
    _tracksController.addPageRequestListener((pageKey) {
      _fetchTracks(pageKey);
    });
  }

  PlaylistTrackSource? get selectedTrackSource => _selectedTrackSource;

  TextEditingController get searchInputController => _searchInputController;

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _tracksOp?.cancel();
    _tracksController.dispose();
    super.dispose();
  }

  String get playlistId => args.playlist.id;

  /*
   * API: TRACK List
   */

  Future<void> _fetchTracks(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _tracksOp?.cancel();

      // Create Request
      _tracksOp = async.CancelableOperation.fromFuture(
        _getTracksFuture(page: pageKey),
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

  Future<Result<ListPage<Track>>> _getTracksFuture({
    required int page,
  }) {
    switch (selectedTrackSource) {
      case PlaylistTrackSource.suggested:
        return locator<KwotData>().playlistsRepository.fetchSuggestedTracks(
              PlaylistSuggestedTracksRequest(
                playlistId: playlistId,
                page: page,
                query: searchQuery,
              ),
            );
      case PlaylistTrackSource.recentlyPlayed:
        return locator<KwotData>().libraryRepository.fetchPlayedTracks(
              PlayedTracksRequest(
                page: page,
                query: searchQuery,
              ),
            );
      case PlaylistTrackSource.liked:
        return locator<KwotData>().libraryRepository.fetchLikedTracks(
              LikedTracksRequest(
                page: page,
                query: searchQuery,
              ),
            );
      case null:
        return locator<KwotData>().tracksRepository.fetchTracks(
              TracksRequest(
                page: page,
                query: searchQuery,
              ),
            );
    }
  }

  @override
  void updateSearchQuery(String? text) {
    if (text != null && text.isNotEmpty) {
      _selectedTrackSource = null;
    } else {
      _selectedTrackSource ??= PlaylistTrackSource.suggested;
    }
    notifyListeners();

    super.updateSearchQuery(text);
  }

  @override
  void clearSearchQuery() {
    _selectedTrackSource = PlaylistTrackSource.suggested;
    notifyListeners();

    super.clearSearchQuery();
  }

  void setSelectedTrackSource(PlaylistTrackSource source) {
    if (_selectedTrackSource == source) {
      return;
    }

    searchInputController.clear();
    _selectedTrackSource = source;

    _tracksOp?.cancel();

    if (searchQuery != null) {
      updateSearchQuery(null);
    } else {
      notifyListeners();
      onRefresh();
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
   * OnRefreshMixin
   */

  @override
  void onRefresh() {
    _tracksController.refresh();
  }

  /*
   * EVENT:
   *  TrackLikeUpdatedEvent
   *  PlaylistTrackAddedEvent
   *  PlaylistTrackRemovedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      } else if (event is PlaylistTrackAddedEvent) {
        return _handlePlaylistTrackAddedEvent(event);
      } else if (event is PlaylistTrackRemovedEvent) {
        return _handlePlaylistTrackRemovedEvent(event);
      }
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    _tracksController.updateItems<Track>((index, item) {
      return event.update(item);
    });
  }

  void _handlePlaylistTrackAddedEvent(PlaylistTrackAddedEvent event) {
    if (playlistId != event.playlistId) return;
    _tracksController.updateItems<Track>((index, track) {
      return event.update(playlistId: playlistId, track: track);
    });
  }

  void _handlePlaylistTrackRemovedEvent(PlaylistTrackRemovedEvent event) {
    if (playlistId != event.playlistId) return;
    _tracksController.updateItems<Track>((index, track) {
      return event.update(playlistId: playlistId, track: track);
    });
  }
}
