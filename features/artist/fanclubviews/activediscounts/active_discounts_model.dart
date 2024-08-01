import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/artist_discounts.dart';
import 'package:wrapped_infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:kwotapi/src/entities/artist/artist.events.request.dart';
import '../../../../components/kit/theme/dynamic_theme.dart';
import '../../../../components/widgets/list/item_list.model.dart';
import 'package:async/async.dart' as async;

class ActiveDiscountsModel with ChangeNotifier, ItemListModel<ActiveDiscounts> {
  async.CancelableOperation<Result<ListPage<ActiveDiscounts>>>? _discountsOp;
  late final PagingController<int, ActiveDiscounts> _discountsController;

  String? artistId;

  void init() {
    _discountsController =
        PagingController<int, ActiveDiscounts>(firstPageKey: 1);
    _discountsController.addPageRequestListener((pageKey) {
      _fetchDiscounts(pageKey);
    });
  }

  @override
  void dispose() {
    _discountsOp?.cancel();
    _discountsController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */
  String? _appliedSearchQuery;
  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _discountsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _discountsController.refresh();
      notifyListeners();
    }
  }

  void copyDiscountCoupons(String text, context) {
    FlutterClipboard.copy(text).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(
          backgroundColor:DynamicTheme.get(context).background(),
          content: const Text("Copied to clipboard")));
    });
  }
  /*
   * API: Discounts List
   */

  Future<void> _fetchDiscounts(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _discountsOp?.cancel();
      // Create Request
      final request = KArtistEventsRequest(
          feedId: "artist_id:" "$artistId",
          page: pageKey,
          search: _appliedSearchQuery);
      _discountsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.fetchDiscounts(request),
          onCancel: () {
        _discountsController.error = "Cancelled.";
      });
      // Listen for result
      _discountsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _discountsController.error = result.error();
          return;
        }
        final page = result.data();
        final currentItemCount = _discountsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if (page.items != null) {
            _discountsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if (page.items != null) {
            _discountsController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _discountsController.error = error;
    }
  }

  @override
  PagingController<int, ActiveDiscounts> controller() => _discountsController;

  @override
  void refresh({required bool resetPageKey, bool isForceRefresh = false}) {
    _discountsOp?.cancel();

    if (resetPageKey) {
      _discountsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _discountsController.retryLastFailedRequest();
    }
  }
}
