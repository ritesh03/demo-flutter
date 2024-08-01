import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ShowCommentsArgs {
  ShowCommentsArgs({
    required this.id,
  });

  final String id;
}

class ShowCommentsModel with ChangeNotifier, ItemListModel<ItemComment> {
  //=
  final String _receivedShowId;

  late final StreamSubscription<ShowCommentAddedEvent>
      _newShowCommentSubscription;

  ShowCommentsModel({
    required ShowCommentsArgs args,
  }) : _receivedShowId = args.id {
    _listenToNewShowComments();
  }

  async.CancelableOperation<Result<ListPage<ItemComment>>>? _showCommentsOp;
  late final PagingController<int, ItemComment> _showCommentsController;

  VoidCallback? onRefreshListener;

  void init({required VoidCallback onRefreshListener}) {
    _showCommentsController = PagingController(firstPageKey: 1);
    _showCommentsController.addPageRequestListener((pageKey) {
      _fetchShowComments(pageKey);
    });

    this.onRefreshListener = onRefreshListener;
  }

  @override
  void dispose() {
    _newShowCommentSubscription.cancel();
    _showCommentsOp?.cancel();
    _showCommentsController.dispose();
    super.dispose();
  }

  /*
   * API: SHOW COMMENTS
   */

  Future<void> _fetchShowComments(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _showCommentsOp?.cancel();

      // Create Request
      final request = ShowCommentsRequest(
        showId: _receivedShowId,
        page: pageKey,
      );
      _showCommentsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().showsRepository.fetchShowComments(request),
        onCancel: () {
          _showCommentsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _showCommentsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _showCommentsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _showCommentsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _showCommentsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _showCommentsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _showCommentsController.error = error;
    }
  }

  bool hasComments() {
    final itemCount = _showCommentsController.itemList?.length ?? 0;
    return itemCount > 0;
  }

  /*
   * ItemListModel<ShowComment>
   */

  @override
  PagingController<int, ItemComment> controller() => _showCommentsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _showCommentsOp?.cancel();

    if (isForceRefresh) {
      onRefreshListener?.call();
    }

    if (resetPageKey) {
      _showCommentsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _showCommentsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT: ShowCommentAddedEvent
   */

  void _listenToNewShowComments() {
    _newShowCommentSubscription =
        eventBus.on<ShowCommentAddedEvent>().listen((event) {
      //=

      final comments = _showCommentsController.itemList?.toList() ?? [];
      final updatedComments = [event.comment, ...comments];
      _showCommentsController.itemList = updatedComments;
    });
  }
}
