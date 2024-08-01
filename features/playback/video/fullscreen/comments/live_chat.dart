import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';

class LiveChat {
  final bool loading;
  final String? error;
  final List<ItemComment> comments;

  LiveChat({
    this.loading = false,
    this.error,
    required this.comments,
  });

  LiveChat.loading({
    this.loading = true,
  })  : error = null,
        comments = [];

  LiveChat.error(String text)
      : loading = false,
        error = text,
        comments = [];
}

class LiveChatNotifier extends ValueNotifier<LiveChat> {
  LiveChatNotifier() : super(LiveChat(comments: []));
}
