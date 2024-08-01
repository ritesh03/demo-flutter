import 'package:flutter/cupertino.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/exclusive.content.dart';
import 'package:wrapped_infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:kwotapi/src/entities/artist/exclusivecontent/exclusive.content.request.dart';
import '../../../../components/widgets/list/item_list.model.dart';
import 'package:async/async.dart' as async;

class ExclusiveContentViewModel with ChangeNotifier,ItemListModel<ExclusiveContent>{

  async.CancelableOperation<Result<ListPage<ExclusiveContent>>>? _exclusiveContentOp;
  late final PagingController<int, ExclusiveContent> exclusiveController;
  Result<ListPage<ExclusiveContent>>? eventResults;
  bool get canShowCircularProgress => (eventResults != null);

  String? artistId;
  String? type;
  bool showSearchField = true;
  int selectedField = 0;
  void init() {
    exclusiveController =
        PagingController<int, ExclusiveContent>(firstPageKey: 1);
    exclusiveController.addPageRequestListener((pageKey) {
      _fetchExclusiveContent(pageKey);
    });
    exclusiveController.notifyPageRequestListeners(1);
  }

  @override
  void dispose() {
    _exclusiveContentOp?.cancel();
    exclusiveController.dispose();
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
      exclusiveController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      exclusiveController.refresh();
      notifyListeners();
    }
  }



  bool _isEventListEmpty = false;
  bool get isEventListEmpty => _isEventListEmpty;
  int? _eventCount;

  /*
   * API: Discounts List
   */

  Future<void> _fetchExclusiveContent(int pageKey,) async {
    try {
      // Cancel current operation (if any)
      _exclusiveContentOp?.cancel();

      if (pageKey == 1) {
        _eventCount = null;
      }

      if (eventResults != null) {
        eventResults = null;
        notifyListeners();
      }
      // Create Request
      final request = KExclusiveContentRequest(
          feedId: "63971029624be6a835fe782a",
          page: pageKey,
          search: _appliedSearchQuery, type: type??"songs");
      _exclusiveContentOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.fetchExclusiveContent(request),
          onCancel: () {
            exclusiveController.error = "Cancelled.";
          });
      // Listen for result
      eventResults = await _exclusiveContentOp?.value;
      if (request.search == null && eventResults!.isEmpty()) {
        _isEventListEmpty = true;
        notifyListeners();
      }
      final page = eventResults!.data();
      if (request.search == null && page.totalItems == 0) {
        _isEventListEmpty = true;
        notifyListeners();
      }

      if (_eventCount == null) {
        _eventCount = page.totalItems;
        notifyListeners();
      }



      _exclusiveContentOp?.value.then((result) {
        if (!result.isSuccess()) {
          exclusiveController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = exclusiveController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if (page.items != null) {
            exclusiveController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if (page.items != null) {
            exclusiveController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      exclusiveController.error = error;
    }
  }








  @override
  PagingController<int, ExclusiveContent> controller() =>exclusiveController;

  @override
  void refresh({required bool resetPageKey, bool isForceRefresh = false}) {
    _exclusiveContentOp?.cancel();

    if (resetPageKey) {
      exclusiveController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      exclusiveController.retryLastFailedRequest();
    }
  }


}