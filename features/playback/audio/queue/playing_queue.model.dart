import 'dart:async';
import 'dart:math' as math;

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/util/paging_controller.ext.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PlayingQueueModel with ChangeNotifier, ItemListModel<PlaybackItem> {
  late final StreamSubscription _playbackItemSubscription;
  late final StreamSubscription _playingQueueSubscription;
  late final StreamSubscription _shuffleModeSubscription;
  late final StreamSubscription _eventsSubscription;

  PlayingQueueModel() {
    _playbackItemSubscription = _listenToPlaybackItemUpdates();
    _playingQueueSubscription = _listenToPlayingQueueUpdates();
    _shuffleModeSubscription = _listenToShuffleModeUpdates();
    _eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<ListOffset<PlaybackItem>>>? _playingQueueOp;
  late final PagingController<int, PlaybackItem> _playingQueueController;

  int? _currentPlayQueueVersion;
  bool? _currentShuffleEnabled;
  PlaybackItem? _currentPlaybackItem;
  int? _currentPlayingItemIndex;

  void init() {
    _playingQueueController =
        PagingController<int, PlaybackItem>(firstPageKey: 0);
    _playingQueueController.addPageRequestListener((offset) {
      _fetchPlayingQueue(offset);
    });
  }

  int get currentPlayingItemIndex => _currentPlayingItemIndex ?? -1;

  int? get nextPlayingItemCount {
    final itemCount = _playingQueueController.itemList?.length;
    if (itemCount == null) return null;

    final remainingItems = itemCount - currentPlayingItemIndex - 1;
    return math.max(0, remainingItems);
  }

  @override
  void dispose() {
    _playbackItemSubscription.cancel();
    _playingQueueSubscription.cancel();
    _shuffleModeSubscription.cancel();
    _eventsSubscription.cancel();
    _playingQueueOp?.cancel();
    _playingQueueController.dispose();
    super.dispose();
  }

  /*
   * API: PLAYING QUEUE
   */

  bool get canClearPlayingQueue {
    final valueStream = locator<KwotData>().playQueueRepository.playQueueStream;
    if (valueStream.hasValue) {
      return !valueStream.value.isEmpty;
    }

    return true;
  }

  Future<void> _fetchPlayingQueue(int offset) async {
    try {
      // Cancel current operation (if any)
      _playingQueueOp?.cancel();

      // Create Request
      final request = PlayQueueRequest(offset: offset, allowCache: true);
      _playingQueueOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().playQueueRepository.fetchItems(request: request),
        onCancel: () {
          _playingQueueController.error = "Cancelled.";
        },
      );

      // Listen for result
      _playingQueueOp?.value.then((result) {
        if (!result.isSuccess()) {
          _playingQueueController.error = result.error();
          return;
        }

        if (result.isEmpty()) {
          _playingQueueController.appendLastPage([]);
          return;
        }

        final listOffset = result.data();
        final isLastPage = listOffset.isLastPage();

        if (isLastPage) {
          _playingQueueController.appendLastPage(listOffset.items);
        } else {
          _playingQueueController.appendPage(
              listOffset.items, listOffset.nextOffset);
        }

        _onCurrentPlayingPlaybackItemChanged(_currentPlaybackItem);
        notifyListeners();
      });
    } catch (error) {
      _playingQueueController.error = error;
    }
  }

  void clearPlayingQueue() {
    // Cancel current fetch-operation (if any)
    _playingQueueOp?.cancel();

    locator<AudioPlaybackActionsModel>().stopPlayback();
  }

  /*
   * ItemListModel<PlaybackItem>
   */

  @override
  PagingController<int, PlaybackItem> controller() => _playingQueueController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _playingQueueOp?.cancel();

    if (resetPageKey) {
      _playingQueueController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _playingQueueController.retryLastFailedRequest();
    }
  }

  StreamSubscription _listenToPlaybackItemUpdates() {
    return audioPlayerManager.playbackItemStream.listen((playbackItem) {
      _currentPlaybackItem = playbackItem;
      _onCurrentPlayingPlaybackItemChanged(playbackItem);
    });
  }

  void _onCurrentPlayingPlaybackItemChanged(PlaybackItem? playbackItem) {
    if (playbackItem == null) return;

    final queuedPlaybackItems = _playingQueueController.itemList?.toList();
    final playingItemIndex = queuedPlaybackItems?.indexWhere((item) {
      return item.playbackId == playbackItem.playbackId;
    });

    if (_currentPlayingItemIndex != playingItemIndex) {
      _currentPlayingItemIndex = playingItemIndex;
      notifyListeners();
    }
  }

  StreamSubscription _listenToPlayingQueueUpdates() {
    return locator<KwotData>().playQueueRepository.playQueueStream.listen(
      (playQueue) {
        if (_currentPlayQueueVersion != null &&
            _currentPlayQueueVersion != playQueue.version) {
          debugPrint("|> PQM: Play Queue version has changed. Refreshing..");
          _currentPlayQueueVersion = null;
          _playingQueueController.refresh();
          notifyListeners();
          return;
        }

        _currentPlayQueueVersion = playQueue.version;
        if (playQueue.isEmpty) {
          debugPrint("|> PQM: Play queue is empty, Refreshing..");
          _playingQueueController.refresh();
          notifyListeners();
          return;
        }
      },
    );
  }

  StreamSubscription _listenToShuffleModeUpdates() {
    return locator<KwotData>()
        .playQueueRepository
        .shuffledStream
        .distinct()
        .listen((shuffled) {
      if (_currentShuffleEnabled != null &&
          _currentShuffleEnabled != shuffled) {
        debugPrint("|> PQM: Play Queue shuffle has changed. Refreshing..");
        _currentPlayQueueVersion = null;
        _currentShuffleEnabled = shuffled;
        _playingQueueController.refresh();
        notifyListeners();
        return;
      }

      _currentShuffleEnabled = shuffled;
    });
  }

  /*
   * EVENT:
   *   TrackLikeUpdatedEvent,
   *   PlayingQueueItemRemovedEvent,
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is TrackLikeUpdatedEvent) {
        return _handleTrackLikeUpdatedEvent(event);
      } else if (event is PlayingQueueItemRemovedEvent) {
        return _handlePlayingQueueItemRemovedEvent(event);
      }
    });
  }

  void _handleTrackLikeUpdatedEvent(TrackLikeUpdatedEvent event) {
    _playingQueueController.updateItems<PlaybackItem>((index, item) {
      if (item.kind == PlaybackKind.track) {
        final updatedTrack = event.update(item.data as Track);
        return item.copyTrack(updatedTrack);
      }
      return item;
    });
  }

  void _handlePlayingQueueItemRemovedEvent(PlayingQueueItemRemovedEvent event) {
    final removedItems = _playingQueueController.applyFilterWhere<PlaybackItem>(
      (item) => item.playbackId != event.item.playbackId,
    );

    final nextPageKey = _playingQueueController.nextPageKey;
    if (nextPageKey != null) {
      _playingQueueController.nextPageKey = nextPageKey - removedItems;
    }
  }
}
