import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'playlists.args.dart';
import 'usecase/playlists_use_case.dart';
import 'usecase/feed_playlists_use_case.dart';
import 'usecase/user_playlists_use_case.dart';

class PlaylistsModel
    with
        ChangeNotifier,
        ItemListModel<Playlist>,
        ItemListViewModeMixin,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  final PlaylistsArgs args;
  late PlaylistsUseCase _playlistsUseCase;

  String? _pageTitle;

  late final StreamSubscription _eventsSubscription;

  PlaylistsModel({
    required this.args,
  }) {
    _eventsSubscription = _listenToEvents();

    final feed = args.feed;
    if (feed != null) {
      final useCase = FeedPlaylistsUseCase(feed: feed);
      setViewMode(useCase.itemListViewMode);
      _playlistsUseCase = useCase;
      return;
    }

    final user = args.user;
    if (user != null) {
      _playlistsUseCase = UserPlaylistsUseCase(user: user);
      return;
    }

    throw Exception("Failed to initialize playlists use-case.");
  }

  async.CancelableOperation<Result<ListPage<Playlist>>>? _playlistsOp;
  late final PagingController<int, Playlist> _playlistsController;

  void init() {
    _playlistsController = PagingController<int, Playlist>(firstPageKey: 1);
    _playlistsController.addPageRequestListener((pageKey) {
      _fetchPlaylists(pageKey);
    });
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _playlistsOp?.cancel();
    _playlistsController.dispose();
    super.dispose();
  }

  String getPageTitle(BuildContext context) {
    return _pageTitle ??= (_playlistsUseCase.getPageTitle(
          context,
          hasSearchQuery: hasSearchQuery,
        ) ??
        LocaleResources.of(context).playlists);
  }

  /*
   * API: Playlist List
   */

  Future<void> _fetchPlaylists(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _playlistsOp?.cancel();

      // Create Request
      _playlistsOp = async.CancelableOperation.fromFuture(
        _playlistsUseCase.fetchPlaylists(page: pageKey, query: searchQuery),
        onCancel: () {
          _playlistsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _playlistsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _playlistsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _playlistsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {

          _playlistsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _playlistsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _playlistsController.error = error;
    }
  }

  /*
   * ItemListModel<Playlist>
   */

  @override
  PagingController<int, Playlist> controller() => _playlistsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _playlistsOp?.cancel();

    if (resetPageKey) {
      _playlistsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _playlistsController.retryLastFailedRequest();
    }
  }

  /*
   * RefreshPageMixin
   */

  @override
  void onRefresh() {
    _playlistsController.refresh();
  }

  /*
   * EVENT:
   *  PlaylistLikeUpdatedEvent,
   *  PlaylistUpdatedEvent,
   *  PlaylistDeletedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is PlaylistLikeUpdatedEvent) {
        return _handlePlaylistLikeUpdatedEvent(event);
      } else if (event is PlaylistUpdatedEvent) {
        return _handlePlaylistUpdatedEvent(event);
      } else if (event is PlaylistDeletedEvent) {
        return _handlePlaylistDeletedEvent(event);
      }
    });
  }

  void _handlePlaylistLikeUpdatedEvent(PlaylistLikeUpdatedEvent event) {
    _playlistsController.updateItems<Playlist>((index, item) {
      return event.update(item);
    });
  }

  void _handlePlaylistUpdatedEvent(PlaylistUpdatedEvent event) {
    _playlistsController.updateItems<Playlist>((index, item) {
      return event.update(item);
    });
  }

  void _handlePlaylistDeletedEvent(PlaylistDeletedEvent event) {
    _playlistsController.removeItemWhere<Playlist>((item) {
      return item.id == event.playlistId;
    });
  }
}
