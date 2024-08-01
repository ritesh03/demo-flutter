import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../util/get_currency_rate.dart';

class MusicHomeModel with ChangeNotifier, ItemListModel<Feed> {
  //=

  async.CancelableOperation<Result<ListPage<Feed>>>? _feedOp;
  final _feedController = PagingController<int, Feed>(firstPageKey: 1);

  Future<void> init() async {
    _feedController.addPageRequestListener((pageKey) {
      _fetchMusicHomeFeed(pageKey);
    });
     await GetCurrency.fetchCurrency();
  }

  @override
  void dispose() {
    _feedOp?.cancel();
    _feedController.dispose();
    super.dispose();
  }

  Future<void> _fetchMusicHomeFeed(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _feedOp?.cancel();

      // Create Request
      final request =
          MusicFeedRequest(page: pageKey, selectedGenres: selectedGenres);
      _feedOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().dashboardRepository.fetchMusicFeed(request),
        onCancel: () {
          _feedController.error = "Cancelled.";
        },
      );

      // Listen for result
      _feedOp?.value.then((result) {
        if (!result.isSuccess()) {
          _feedController.error = result.error();
          return;
        }

        if (result.isEmpty()) {
          _feedController.appendLastPage([]);
          return;
        }

        final page = result.data();
        final currentItemCount = _feedController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _feedController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _feedController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _feedController.error = error;
    }
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, Feed> controller() => _feedController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _feedOp?.cancel();

    if (resetPageKey) {
      _feedController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _feedController.retryLastFailedRequest();
    }
  }

  /*
   * GENRE SELECTION
   */

  List<MusicGenre> _selectedMusicGenres = [];

  bool get filtered => _selectedMusicGenres.isNotEmpty;

  List<MusicGenre> get selectedGenres => _selectedMusicGenres;

  void setSelectedGenres(List<MusicGenre> genres) {
    _selectedMusicGenres = genres;
    _feedController.refresh();
    notifyListeners();
  }

  void removeSelectedGenre(MusicGenre genre) {
    final selectedGenres = _selectedMusicGenres.toList();
    selectedGenres.removeWhere((element) => (element.id == genre.id));

    _selectedMusicGenres = selectedGenres;
    _feedController.refresh();
    notifyListeners();
  }
}
