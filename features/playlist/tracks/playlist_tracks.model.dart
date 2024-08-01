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

import 'playlist_tracks.args.dart';

class PlaylistTracksModel with ChangeNotifier, ItemListModel<Track> {
  //=
  late Playlist playlist;
  late PlaylistTracksFilter filter;

  ItemListViewMode _viewMode = ItemListViewMode.list;
  final searchQueryController = TextEditingController();

  late final StreamSubscription _eventsSubscription;

  PlaylistTracksModel({
    required PlaylistTracksArgs args,
  }) {
    playlist = args.playlist;

    searchQueryController.text = args.searchQuery ?? "";
    filter = PlaylistTracksFilter(
      query: args.searchQuery,
      sortBy: args.sortBy ?? PlaylistTrackSortBy.recentlyAdded,
    );

    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<Track>>>? _tracksOp;
  late final PagingController<int, Track> _tracksController;

  void init() {
    _tracksController = PagingController<int, Track>(firstPageKey: 1);
    _tracksController.addPageRequestListener((pageKey) {
      _fetchTracks(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _tracksOp?.cancel();
    _tracksController.dispose();
    super.dispose();
  }

  /*
   * Search Playlist Tracks
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
   * Sort Playlist Tracks
   */

  bool get hasCustomSort => filter.sortBy != PlaylistTrackSortBy.recentlyAdded;

  PlaylistTrackSortBy get selectedSortBy => filter.sortBy;

  void setSelectedSortBy(PlaylistTrackSortBy sortBy) {
    if (sortBy == selectedSortBy) {
      notifyListeners();
      return;
    }

    filter = filter.copyWithSortBy(sortBy: sortBy);
    _tracksController.refresh();
    notifyListeners();
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
      final request = PlaylistTracksRequest(
        playlistId: playlist.id,
        page: pageKey,
        query: filter.query,
        sortBy: filter.sortBy,
      );
      _tracksOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().playlistsRepository.fetchPlaylistTracks(request),
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

  PlayTrackRequest createPlayTrackRequest(Track track) {
    return PlayTrackRequest.playlist(
      playlist.id,
      track: track,
      query: filter.query,
      playlistTrackSortBy: filter.sortBy,
    );
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
   *  PlaylistTrackAddedEvent
   *  PlaylistTracksAddedEvent
   *  PlaylistTrackRemovedEvent
   *  PlaylistDeletedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      } else if (event is PlaylistTrackAddedEvent) {
        return _handlePlaylistTrackAddedEvent(event);
      } else if (event is PlaylistTracksAddedEvent) {
        return _handlePlaylistTracksAddedEvent(event);
      } else if (event is PlaylistTrackRemovedEvent) {
        return _handlePlaylistTrackRemovedEvent(event);
      } else if (event is PlaylistDeletedEvent) {
        return _handlePlaylistDeletedEvent(event);
      }
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    _tracksController.updateItems<Track>((index, item) {
      return event.update(item);
    });
  }

  void _handlePlaylistTrackAddedEvent(PlaylistTrackAddedEvent event) {
    if (playlist.id != event.playlistId) return;
    final addedTrack = event.track;
    if (addedTrack == null) return;

    _tracksController.insert<Track>(
      0,
      event.update(playlistId: playlist.id, track: addedTrack),
    );
  }

  void _handlePlaylistTracksAddedEvent(PlaylistTracksAddedEvent event) {
    if (playlist.id != event.id) return;
    _tracksController.refresh();
  }

  void _handlePlaylistTrackRemovedEvent(PlaylistTrackRemovedEvent event) {
    if (playlist.id != event.playlistId) return;
    _tracksController.removeItemWhere<Track>(
        (item) => item.playlistInfo?.playlistItemId == event.playlistItemId);
  }

  void _handlePlaylistDeletedEvent(PlaylistDeletedEvent event) {
    if (playlist.id != event.playlistId) return;
    _tracksController.refresh();
  }
}
