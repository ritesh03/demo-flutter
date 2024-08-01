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

class ArtistListArgs {
  ArtistListArgs({
    this.availableFeed,
    this.enableGenreFilter = false,
  });

  final Feed<Artist>? availableFeed;
  final bool enableGenreFilter;
}

class ArtistsModel with ChangeNotifier, ItemListModel<Artist> {
  //=
  final Feed<Artist>? _initialFeed;
  late ArtistsFilter filter;
  late final bool _isGenreFilterEnabled;

  ItemListViewMode _viewMode = ItemListViewMode.list;

  late final StreamSubscription _eventsSubscription;

  ArtistsModel({
    required ArtistListArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = ArtistsFilter(query: null, genres: []);
    _isGenreFilterEnabled = args.enableGenreFilter;

    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListPage<Artist>>>? _artistsOp;
  late final PagingController<int, Artist> _artistsController;

  void init() {
    final initialFeed = _initialFeed;
    if (initialFeed != null) {
      _viewMode = createViewModeFromFeed(initialFeed);
    }

    _artistsController = PagingController<int, Artist>(firstPageKey: 1);
    _artistsController.addPageRequestListener((pageKey) {
      _fetchArtists(pageKey);
    });
  }

  bool get canSearchInFeed => _initialFeed?.searchable ?? false;

  @override
  void dispose() {
    _eventsSubscription.cancel();

    _artistsOp?.cancel();
    _artistsController.dispose();
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
      _artistsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      _artistsController.refresh();
      notifyListeners();
    }
  }

  /*
   * ARTISTS filter
   */

  List<MusicGenre> get selectedGenres => filter.genres.toList();

  bool get canShowGenreFilter => _isGenreFilterEnabled;

  bool get filtered => filter.hasGenres;

  void setSelectedGenres(List<MusicGenre> genres) {
    if (!_isGenreFilterEnabled) return;

    final selectedGenres = filter.genres;
    if (selectedGenres.isEmpty && genres.isEmpty) {
      notifyListeners();
      return;
    }

    filter = filter.copyWithGenres(genres: genres);
    _artistsController.refresh();
    notifyListeners();
  }

  void removeSelectedGenre(MusicGenre genre) {
    if (!_isGenreFilterEnabled) return;

    final selectedGenres = filter.genres.toList();
    selectedGenres.removeWhere((element) => (element.id == genre.id));
    filter = filter.copyWithGenres(genres: selectedGenres);

    _artistsController.refresh();
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
        return 3;
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
   * API: Artist List
   */

  Future<void> _fetchArtists(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _artistsOp?.cancel();

      // Create Request
      final request = ArtistsRequest(
        feedId: !canSearchInFeed && (filter.hasSearchQuery || filter.hasGenres)
            ? null
            : _initialFeed?.id,
        genres: _isGenreFilterEnabled ? filter.genres : null,
        page: pageKey,
        query: filter.query,
      );
      _artistsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().artistsRepository.fetchArtists(request),
        onCancel: () {
          _artistsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _artistsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _artistsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _artistsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _artistsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _artistsController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _artistsController.error = error;
    }
  }

  /*
   * ItemListModel<Artist>
   */

  @override
  PagingController<int, Artist> controller() => _artistsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _artistsOp?.cancel();

    if (resetPageKey) {
      _artistsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _artistsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT: ArtistBlockUpdatedEvent, ArtistFollowUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    _artistsController.updateItems<Artist>((index, item) {
      return event.update(item);
    });
  }
}
