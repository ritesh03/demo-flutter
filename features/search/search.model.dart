import 'dart:async';
import 'package:async/async.dart' as async;

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'search_catalog.usecase.dart';

class SearchArgs {
  SearchArgs({
    required this.source,
    this.searchPlace = AppConfig.defaultSearchPlace,
    this.searchKind,
  });

  final SearchSource source;
  final SearchPlace searchPlace;
  final SearchKind? searchKind;
}

class SearchModel with ChangeNotifier, ItemListModel<SearchResultItem> {
  SearchSource source;
  SearchPlace _searchPlace;
  SearchKind? _searchKind;
  String? _searchQuery;

  final _searchCatalogUseCase = SearchCatalogUseCase();
  SearchCatalog? _searchCatalog;
  StreamSubscription? _eventsSubscription;

  async.CancelableOperation<SearchCatalog>? _itemsOp;
  late final PagingController<int, SearchResultItem> _itemsController;

  SearchModel({
    required SearchArgs args,
  })  : source = args.source,
        _searchPlace = args.searchPlace {
    _searchKind = args.searchKind;
    _searchQuery = null;

    _eventsSubscription = _listenToEvents();
    _itemsController = PagingController(firstPageKey: 1);
    _itemsController.addPageRequestListener((pageKey) {
      _fetchItems(pageKey);
    });
  }

  SearchKind? get searchKind => _searchKind;

  SearchPlace get searchPlace => _searchPlace;

  String? get searchQuery => _searchQuery;

  SearchCatalogType get searchCatalogType {
    if (_searchCatalog != null) {
      return _searchCatalog!.type;
    }

    if (searchQuery == null || searchQuery!.trim().isEmpty) {
      return SearchCatalogType.recentSearches;
    }

    return SearchCatalogType.searchResults;
  }

  bool get canShowClearRecentSearchesOption {
    if (searchCatalogType != SearchCatalogType.recentSearches) {
      return false;
    }

    return _itemsController.itemList?.isNotEmpty ?? false;
  }

  bool get hasEmptySearchResults {
    return searchQuery != null &&
        searchQuery!.trim().isNotEmpty &&
        searchCatalogType == SearchCatalogType.trendingSearches;
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _itemsOp?.cancel();
    _itemsController.dispose();
    super.dispose();
  }

  void updateSearchKind(SearchKind? updatedSearchKind) {
    final oldSearchKind = searchKind;
    if (oldSearchKind == updatedSearchKind) {
      return;
    }

    _searchKind = updatedSearchKind;
    _itemsOp?.cancel().whenComplete(() {
      _itemsOp = null;
      _itemsController.refresh();
    });
    notifyListeners();
  }

  void updateSearchPlace(SearchPlace updatedSearchPlace) {
    final oldSearchPlace = searchPlace;
    if (oldSearchPlace == updatedSearchPlace) {
      return;
    }

    _searchPlace = updatedSearchPlace;
    _itemsOp?.cancel().whenComplete(() {
      _itemsOp = null;
      _itemsController.refresh();
    });
    notifyListeners();
  }

  void updateSearchQuery(String? updatedSearchQuery) {
    final oldSearchQuery = searchQuery;
    if (oldSearchQuery == updatedSearchQuery) {
      return;
    }

    _searchQuery = updatedSearchQuery;
    _itemsOp?.cancel().whenComplete(() {
      _itemsOp = null;
      _itemsController.refresh();
    });
    notifyListeners();
  }

  Future<void> _fetchItems(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _itemsOp?.cancel();

      if (pageKey == 1 && _searchCatalog != null) {
        _searchCatalog = null;
        notifyListeners();
      }

      // Create Request
      final request = SearchCatalogRequest(
        kind: _searchKind,
        page: pageKey,
        searchPlace: searchPlace,
        query: _searchQuery,
      );
      _itemsOp = async.CancelableOperation.fromFuture(
        _searchCatalogUseCase.searchCatalog(request),
        onCancel: () {
          _itemsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _itemsOp?.value.then((searchCatalog) {
        _searchCatalog = searchCatalog;
        final result = searchCatalog.itemsResult;

        if (!result.isSuccess()) {
          _searchCatalog = null;
          _itemsController.error = result.error();
          notifyListeners();
          return;
        }

        if (result.isEmpty() || result.data().isEmpty) {
          _itemsController.appendLastPage([]);
          notifyListeners();
          return;
        }

        final page = result.data();
        final currentItemCount = _itemsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _itemsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _itemsController.appendPage(page.items??[], nextPageKey);
        }
        notifyListeners();
      });
    } catch (error) {
      _searchCatalog = null;
      _itemsController.error = error;
      notifyListeners();
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, SearchResultItem> controller() => _itemsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _itemsOp?.cancel();

    if (resetPageKey) {
      _itemsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _itemsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT:
   *  ArtistFollowUpdatedEvent,
   *  UserBlockUpdatedEvent,
   *  UserFollowUpdatedEvent,
   *  PodcastLikeUpdatedEvent,
   *  PodcastEpisodeLikeUpdatedEvent
   *  RadioStationLikeUpdatedEvent
   *  ShowLikeUpdatedEvent
   *  ShowReminderUpdatedEvent
   *  SkitLikeUpdatedEvent
   *  TrackLikeUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on<Event>().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      } else if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      } else if (event is UserFollowUpdatedEvent) {
        return _handleUserFollowEvent(event);
      } else if (event is PodcastLikeUpdatedEvent) {
        return _handlePodcastLikeEvent(event);
      } else if (event is PodcastEpisodeLikeUpdatedEvent) {
        return _handlePodcastEpisodeLikeEvent(event);
      } else if (event is RadioStationLikeUpdatedEvent) {
        return _handleRadioStationLikeEvent(event);
      } else if (event is ShowLikeUpdatedEvent) {
        return _handleShowLikeEvent(event);
      } else if (event is ShowReminderUpdatedEvent) {
        return _handleShowReminderEvent(event);
      } else if (event is SkitLikeUpdatedEvent) {
        return _handleSkitLikeEvent(event);
      } else if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeEvent(event);
      } else if (event is RecentSearchItemAddedEvent) {
        _handleRecentSearchItemAddedEvent(event);
      } else if (event is RecentSearchItemRemovedEvent) {
        _handleRecentSearchItemRemovedEvent(event);
      } else if (event is RecentSearchesClearedEvent) {
        _handleRecentSearchesClearedEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.artist) return item;
      if (item.id != event.artistId) return item;
      return item.copyWith(data: event.update(item.data as Artist));
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.user) return item;
      if (item.id != event.userId) return item;
      return item.copyWith(data: event.update(item.data as User));
    });
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.user) return item;
      if (item.id != event.userId) return item;
      return item.copyWith(data: event.update(item.data as User));
    });
  }

  void _handlePodcastLikeEvent(PodcastLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.podcast) return item;
      if (item.id != event.id) return item;
      return item.copyWith(data: event.update(item.data as Podcast));
    });
  }

  void _handlePodcastEpisodeLikeEvent(PodcastEpisodeLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.podcastEpisode) return item;
      if (item.id != event.episodeId) return item;
      return item.copyWith(data: event.update(item.data as PodcastEpisode));
    });
  }

  void _handleRadioStationLikeEvent(RadioStationLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.radioStation) return item;
      if (item.id != event.id) return item;
      return item.copyWith(data: event.update(item.data as RadioStation));
    });
  }

  void _handleShowLikeEvent(ShowLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.show) return item;
      if (item.id != event.showId) return item;
      return item.copyWith(data: event.update(item.data as Show));
    });
  }

  void _handleShowReminderEvent(ShowReminderUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.show) return item;
      if (item.id != event.showId) return item;
      return item.copyWith(data: event.update(item.data as Show));
    });
  }

  void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.skit) return item;
      if (item.id != event.skitId) return item;
      return item.copyWith(data: event.update(item.data as Skit));
    });
  }

  void _handleTrackLikeEvent(TrackLikeUpdatedEvent event) {
    _itemsController.updateItems<SearchResultItem>((index, item) {
      if (item.kind != SearchKind.track) return item;
      if (item.id != event.id) return item;
      return item.copyWith(data: event.update(item.data as Track));
    });
  }

  void _handleRecentSearchItemAddedEvent(RecentSearchItemAddedEvent event) {
    final retrievedSearchCatalogType = _searchCatalog?.type;
    if (retrievedSearchCatalogType == null ||
        retrievedSearchCatalogType != SearchCatalogType.recentSearches) {
      return;
    }

    final retrievedSearchKind = _searchCatalog?.request.kind;
    if (retrievedSearchKind != null && retrievedSearchKind != event.item.kind) {
      return;
    }

    _itemsController.updateItemList((items) {
      return items
        ..removeWhere((item) => item.id == event.item.id)
        ..insert(0, event.item);
    });
    notifyListeners();
  }

  void _handleRecentSearchItemRemovedEvent(RecentSearchItemRemovedEvent event) {
    final retrievedSearchCatalogType = _searchCatalog?.type;
    if (retrievedSearchCatalogType == null ||
        retrievedSearchCatalogType != SearchCatalogType.recentSearches) {
      return;
    }

    final retrievedSearchKind = _searchCatalog?.request.kind;
    if (retrievedSearchKind != null && retrievedSearchKind != event.item.kind) {
      return;
    }

    _itemsController.updateItemList((items) {
      return items..removeWhere((item) => item.id == event.item.id);
    });
    notifyListeners();
  }

  void _handleRecentSearchesClearedEvent(RecentSearchesClearedEvent event) {
    final retrievedSearchCatalogType = _searchCatalog?.type;
    if (retrievedSearchCatalogType == null ||
        retrievedSearchCatalogType != SearchCatalogType.recentSearches) {
      return;
    }

    _itemsOp?.cancel().whenComplete(() {
      _itemsOp = null;
      _itemsController.refresh();
      notifyListeners();
    });
  }
}
