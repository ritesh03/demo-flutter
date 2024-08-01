import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/model/mixin_on_refresh.dart';
import 'package:kwotmusic/components/model/mixin_search_query.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AddToPlaylistModel
    with
        ChangeNotifier,
        ItemListModel<Playlist>,
        OnRefreshMixin,
        SearchQueryMixin {
  //=
  final Track? track;
  final Album? album;

  AddToPlaylistModel.track(this.track) : album = null;

  AddToPlaylistModel.album(this.album) : track = null;

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
    _playlistsOp?.cancel();
    _playlistsController.dispose();
    super.dispose();
  }

  /*
   * API: Playlist List
   */

  Future<void> _fetchPlaylists(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _playlistsOp?.cancel();

      // Create Request
      final userId = locator<KwotData>().storageRepository.getUserId();
      final request = PlaylistsRequest(page: pageKey, userId: userId);
      _playlistsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().playlistsRepository.fetchPlaylists(request),
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
          if(page.items != null) {
            _playlistsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _playlistsController.appendPage(page.items!, nextPageKey);
          }
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
}
