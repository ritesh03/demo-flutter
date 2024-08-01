import 'package:flutter/foundation.dart';
import 'package:kwotdata/kwotdata.dart';

enum ItemListViewMode { list, grid }

extension ItemListViewModeExtension on ItemListViewMode {
  bool get isListMode => (this == ItemListViewMode.list);

  bool get isGridMode => (this == ItemListViewMode.grid);

  int get columnCount {
    switch (this) {
      case ItemListViewMode.list:
        return 1;
      case ItemListViewMode.grid:
        return 2;
    }
  }
}

ItemListViewMode createViewModeFromFeed(Feed feed) {
  switch (feed.structure) {
    case FeedStructure.listItemNx1:
    case FeedStructure.pagedListItem4xN:
    case FeedStructure.pagedListItem1xN:
      return ItemListViewMode.list;

    case FeedStructure.gridItem1xN:
    case FeedStructure.gridItem2x2:
    case FeedStructure.pagedGridItem1xN:
      return ItemListViewMode.grid;
  }
}

mixin ItemListViewModeMixin on ChangeNotifier {
  ItemListViewMode _viewMode = ItemListViewMode.list;

  ItemListViewMode get viewMode => _viewMode;

  void setViewMode(ItemListViewMode viewMode) {
    _viewMode = viewMode;
    notifyListeners();
  }

  void setListViewMode() {
    setViewMode(ItemListViewMode.list);
  }

  void setGridViewMode() {
    setViewMode(ItemListViewMode.grid);
  }
}
