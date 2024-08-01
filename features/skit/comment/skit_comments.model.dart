import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SkitCommentsArgs {
  SkitCommentsArgs({
    required this.id,
  });

  final String id;
}

class SkitCommentsModel with ChangeNotifier, ItemListModel<ItemComment> {
  //=
  final String _receivedSkitId;

  late final StreamSubscription<SkitCommentAddedEvent>
      _newSkitCommentSubscription;

  SkitCommentsModel({
    required SkitCommentsArgs args,
  }) : _receivedSkitId = args.id {
    _listenToNewSkitComments();
  }

  async.CancelableOperation<Result<ListPage<ItemComment>>>? _skitCommentsOp;
  late final PagingController<int, ItemComment> _skitCommentsController;

  VoidCallback? onRefreshListener;

  void init({required VoidCallback onRefreshListener}) {
    _skitCommentsController = PagingController(firstPageKey: 1);
    _skitCommentsController.addPageRequestListener((pageKey) {
      _fetchSkitComments(pageKey);
    });

    this.onRefreshListener = onRefreshListener;
  }

  @override
  void dispose() {
    _newSkitCommentSubscription.cancel();
    _skitCommentsOp?.cancel();
    _skitCommentsController.dispose();
    super.dispose();
  }

  int get count {
    return _skitCommentsController.itemList?.length ?? 0;
  }

  /*
   * API: SKIT COMMENTS
   */

  Future<void> _fetchSkitComments(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _skitCommentsOp?.cancel();

      // Create Request
      final request = SkitCommentsRequest(
        skitId: _receivedSkitId,
        page: pageKey,
      );
      _skitCommentsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().skitsRepository.fetchSkitComments(request),
        onCancel: () {
          _skitCommentsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _skitCommentsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _skitCommentsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _skitCommentsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          _skitCommentsController.appendLastPage(page.items??[]);
        } else {
          final nextPageKey = pageKey + 1;
          _skitCommentsController.appendPage(page.items??[], nextPageKey);
        }
      });
    } catch (error) {
      _skitCommentsController.error = error;
    }
  }

  bool hasComments() {
    final itemCount = _skitCommentsController.itemList?.length ?? 0;
    return itemCount > 0;
  }

  /*
   * ItemListModel<SkitComment>
   */

  @override
  PagingController<int, ItemComment> controller() => _skitCommentsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _skitCommentsOp?.cancel();

    if (isForceRefresh) {
      onRefreshListener?.call();
    }

    if (resetPageKey) {
      _skitCommentsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _skitCommentsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT: SkitCommentAddedEvent
   */

  void _listenToNewSkitComments() {
    _newSkitCommentSubscription =
        eventBus.on<SkitCommentAddedEvent>().listen((event) {
      //=
      final comments = _skitCommentsController.itemList?.toList() ?? [];
      if (comments.isEmpty) {
        refresh(resetPageKey: true);
      } else {
        final updatedComments = [event.comment, ...comments];
        _skitCommentsController.itemList = updatedComments;
      }
    });
  }
}
