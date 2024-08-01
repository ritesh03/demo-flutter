import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'albums.args.dart';

class AlbumsModel with ChangeNotifier, ItemListModel<Album> {
  //=
  final Feed<Album>? _initialFeed;
  late AlbumsFilter filter;

  ItemListViewMode _viewMode = ItemListViewMode.list;
  StreamSubscription? _eventsSubscription;

  AlbumsModel({
    required AlbumsListArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = AlbumsFilter(query: null, genres: args.genres ?? []);
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<Album>>>? _albumsOp;
  late final PagingController<int, Album> _albumsController;

  void init() {
    final initialFeed = _initialFeed;
    if (initialFeed != null) {
      _viewMode = createViewModeFromFeed(initialFeed);
    }

    _albumsController = PagingController<int, Album>(firstPageKey: 1);
    _albumsController.addPageRequestListener((pageKey) {
      _fetchAlbums(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _albumsOp?.cancel();
    _albumsController.dispose();
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
      _albumsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      _albumsController.refresh();
      notifyListeners();
    }
  }

  /*
   * Albums filter
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
    _albumsController.refresh();
    notifyListeners();
  }

  void removeSelectedGenre(MusicGenre genre) {
    final selectedGenres = filter.genres.toList();
    selectedGenres.removeWhere((element) => (element.id == genre.id));
    filter = filter.copyWithGenres(genres: selectedGenres);

    _albumsController.refresh();
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
   * API: Album List
   */

  Future<void> _fetchAlbums(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _albumsOp?.cancel();

      // Create Request
      final request = AlbumsRequest(
        feedId: !canSearchInFeed && (filter.hasSearchQuery || filter.hasGenres)
            ? null
            : _initialFeed?.id,
        genres: filter.genres,
        page: pageKey,
        query: filter.query,
      );
      _albumsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().albumsRepository.fetchAlbums(request),
        onCancel: () {
          _albumsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _albumsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _albumsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _albumsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _albumsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _albumsController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _albumsController.error = error;
    }
  }

  /*
   * ItemListModel<Album>
   */

  @override
  PagingController<int, Album> controller() => _albumsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _albumsOp?.cancel();

    if (resetPageKey) {
      _albumsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _albumsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  AlbumLikedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is AlbumLikeUpdatedEvent) {
        return _handleAlbumLikeUpdatedEvent(event);
      }
    });
  }

  void _handleAlbumLikeUpdatedEvent(AlbumLikeUpdatedEvent event) {
    _albumsController.updateItems<Album>((index, item) {
      return event.update(item);
    });
  }
}
