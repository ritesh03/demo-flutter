import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class RecentSearchItemAddedEvent extends Event {
  final SearchResultItem item;

  RecentSearchItemAddedEvent({
    required this.item,
  }) : super(id: item.id);
}

class RecentSearchItemRemovedEvent extends Event {
  final SearchResultItem item;

  RecentSearchItemRemovedEvent({
    required this.item,
  }) : super(id: item.id);
}

class RecentSearchesClearedEvent extends Event {
  RecentSearchesClearedEvent() : super(id: "recent-searches-cleared");
}
