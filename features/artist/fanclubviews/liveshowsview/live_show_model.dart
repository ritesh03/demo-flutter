import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:async/async.dart' as async;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/subscription.plan.artist.dart' as plan;
import 'package:kwotdata/models/liveshows/live_shows.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import '../../../../components/widgets/list/item_list.model.dart';
import '../../../../events/events.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';


class LiveShowModel with ChangeNotifier , ItemListModel<LiveShow> {

  String? _appliedSearchQuery;
  late final PagingController<int, LiveShow> getEventsController;
  async.CancelableOperation<Result<ListPage<LiveShow>>>? _getEventsOp;
  async.CancelableOperation<Result<Profile>>? _profileOp;
  Result<Profile>? profileResult;
  Result<ListPage<LiveShow>>? eventResults;
  async.CancelableOperation<Result<plan.Plan>>? _joinEvent;
  Result<plan.Plan>? joinEventResult;
  late PageController pageController;

  late final StreamSubscription _eventsSubscription;

  bool get canShowCircularProgress => (eventResults != null);
  /*EventMeetModel(){
    _eventsSubscription = _listenToEvents();
  }*/


  void init(String artistId) {
    getEventsController = PagingController<int, LiveShow>(firstPageKey: 1);
    getEventsController.addPageRequestListener((pageKey) {
      fetchArtistEvents(pageKey, artistId);
    });
    getEventsController.notifyPageRequestListeners(0);
  }


  @override
  void dispose() {
    _getEventsOp != null ?
    _getEventsOp!.cancel() : null;
    _joinEvent != null ?
    _joinEvent!.cancel() : null;
    //_profileOp!.cancel();
    getEventsController.dispose();
    super.dispose();
  }

  /*
   * Search Query
   */
  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      getEventsController.refresh();
      notifyListeners();
    }
    getEventsController.notifyListeners();

  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      getEventsController.refresh();
      notifyListeners();
    }
  }

  /*
   * API: Event list api
   */

  bool _isEventListEmpty = false;

  bool get isEventListEmpty => _isEventListEmpty;

  int? _eventCount;

  Future<void> fetchArtistEvents(int pageKey, String artistId) async {
    try {
      // Cancel current operation (if any)
      _getEventsOp?.cancel();

      if (pageKey == 1) {
        _eventCount = null;
      }

      if (eventResults != null) {
        eventResults = null;
        notifyListeners();
      }

      _getEventsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().artistsRepository.fetchLiveShows(artistId: artistId, page: pageKey, search: _appliedSearchQuery??""),
        onCancel: () {
          getEventsController.error = "Cancelled.";
        },
      );
      // Wait for result
      eventResults = await _getEventsOp?.value;
      if (!eventResults!.isSuccess()) {
        getEventsController.error = eventResults!.error();
        return;
      }
      if (_appliedSearchQuery == null && eventResults!.isEmpty()) {
        _isEventListEmpty = true;
        notifyListeners();
      }
      final page = eventResults!.data();
      if (_appliedSearchQuery == null && page.totalItems == 0) {
        _isEventListEmpty = true;
        notifyListeners();
      }
      if (_eventCount == null) {
        _eventCount = page.totalItems;
        notifyListeners();
      }
      final currentItemCount = getEventsController.itemList?.length ?? 0;
      final isLastPage = page.isLastPage(currentItemCount);
      if (isLastPage) {
        getEventsController.appendLastPage(page.items??[]);
      } else {
        final nextPageKey = pageKey + 1;
        getEventsController.appendPage(page.items??[], nextPageKey);
        if(page.items != null ){
          getEventsController.notifyListeners();
        }
      }
    } catch (error) {
      eventResults = Result.error("Error: $error");
    }

    notifyListeners();
  }

/*
  Future<bool> joinEventEvents(context, String eventId) async {
    try {
      showBlockingProgressDialog(context);
      // Cancel current operation (if any)
      _joinEvent?.cancel();

      if (joinEventResult != null) {
        joinEventResult = null;
        notifyListeners();
      }

      // Create Request
      final request = KJoinEventRequest(eventId: eventId);
      _joinEvent = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.joinEvent(request));

      // Wait for result
      joinEventResult = await _joinEvent?.value;
      if (joinEventResult != null) {
        hideBlockingProgressDialog(context);
      }
      if (joinEventResult!.isSuccess()) {
        getEventsController.refresh();
        return true;
      }
      else {
        return false;
      }
    } catch (error) {
      hideBlockingProgressDialog(context);
      joinEventResult = Result.error("Error: $error");
      return false;
    }
  }

  /// Fetch user token to purchase plan
  Future<void> fetchProfile() async {
    // Cancel current operation (if any)
    _profileOp?.cancel();

    if (profileResult != null) {
      profileResult = null;
      notifyListeners();
    }

    // Create Request
    _profileOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchProfile());

    // Wait for result
    profileResult = await _profileOp?.value;
    notifyListeners();
  }*/


  @override
  PagingController<int, LiveShow> controller() => getEventsController;

  @override
  void refresh({required bool resetPageKey, bool isForceRefresh = false}) {
    _getEventsOp?.cancel();

    if (resetPageKey) {
      getEventsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      getEventsController.retryLastFailedRequest();
    }
  }

  /*
   * EVENT: UserBlockUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      }
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    // update list of blocked-users
    getEventsController.updateItems<User>((index, item) {
      return event.update(item);
    });
  }
}








