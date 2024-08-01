import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/playback/video/fullscreen/comments/live_chat.dart';

/// TODO:
/// 1. Post & Handle Errors
/// 2. Community Guidelines
/// 3. Insert Animation?
/// 4. Don't scroll when new comment is added.
///
class ShowLiveChatManager {
  ShowLiveChatManager({
    required this.showId,
    required this.liveChatNotifier,
    required this.shouldNotify,
    required this.onLiveChatUpdated,
  });

  final String showId;
  final LiveChatNotifier liveChatNotifier;
  final bool Function() shouldNotify;
  final ValueSetter<LiveChat> onLiveChatUpdated;

  LiveChat? _latestLiveChat;

  StreamController<ItemComment>? _liveChatStreamController;
  StreamSubscription<ItemComment>? _liveChatStreamSubscription;

  void load() async {
    final currentLiveChat = _latestLiveChat;
    if (currentLiveChat != null) {
      _update(currentLiveChat);
    }

    final previousController = _liveChatStreamController;
    if (previousController == null || previousController.isClosed) {
      _cancelStreamSubscription();
      _update(LiveChat.loading());

      final request = ShowCommentsRequest(showId: showId, page: 1);
      final result = await locator<KwotData>().showsRepository.streamShowComments(request);
      if (!result.isSuccess()) {
        _update(LiveChat.error(result.error()));
        return;
      }

      _liveChatStreamController = result.data();
    }

    final newController = _liveChatStreamController;
    if (newController == null) {
      _update(LiveChat.error("Unknown error"));
      return;
    }

    final subscription = _liveChatStreamSubscription;
    if (subscription != null) {
      return;
    }

    _liveChatStreamSubscription = _liveChatStreamController?.stream.listen(
      /// LISTEN TO DATA
      (comment) {
        final oldLiveChat = _latestLiveChat ?? liveChatNotifier.value;
        final comments = [comment, ...oldLiveChat.comments.take(50)];

        final liveChat = LiveChat(comments: comments);
        _latestLiveChat = liveChat;
        if (shouldNotify()) {
          _update(liveChat);
        }
      },

      /// LISTEN TO ERROR
      onError: (error) {
        _cancelStreamSubscription();

        final liveChat = LiveChat.error(error);
        _latestLiveChat = liveChat;
        if (shouldNotify()) {
          _update(liveChat);
        }
      },
    );
  }

  void refresh() async {
    dispose();
    load();
  }

  void _update(LiveChat liveChat) {
    liveChatNotifier.value = liveChat;
    onLiveChatUpdated(liveChat);
  }

  void _cancelStreamSubscription() {
    _liveChatStreamSubscription?.cancel();
    _liveChatStreamSubscription = null;
  }

  void dispose() {
    _cancelStreamSubscription();
    _liveChatStreamController?.close();
  }
}
