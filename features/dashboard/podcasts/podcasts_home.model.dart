import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PodcastsHomeModel with ChangeNotifier, ItemListModel<Feed> {
  //=

  async.CancelableOperation<Result<ListPage<Feed>>>? _feedOp;
  final _feedController = PagingController<int, Feed>(firstPageKey: 1);

  void init() {
    _feedController.addPageRequestListener((pageKey) {
      _fetchRadioHomeFeed(pageKey);
    });
  }

  @override
  void dispose() {
    _feedOp?.cancel();
    _feedController.dispose();
    super.dispose();
  }

  Future<void> _fetchRadioHomeFeed(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _feedOp?.cancel();

      // Create Request
      final request = RadioFeedRequest(page: pageKey);
      _feedOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().dashboardRepository.fetchRadioFeed(request),
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
}
