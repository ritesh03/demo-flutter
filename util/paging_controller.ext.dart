import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension PagingControllerExtension on PagingController {
  //=

  bool removeItemWhere<T>(bool Function(T item) where) {
    final items = itemList;
    if (items == null || items.isEmpty) {
      return false;
    }

    items as List<T>;
    final index = items.indexWhere(where);
    if (index == -1) {
      return false;
    }

    itemList = items.toList()..removeAt(index);
    return true;
  }

  int applyFilterWhere<T>(bool Function(T item) where) {
    final items = itemList;
    if (items == null || items.isEmpty) {
      return 0;
    }

    itemList = items.toList().where((item) => where(item)).toList();
    return items.length - itemList!.length;
  }

  void insert<T>(int index, T item) {
    final items = itemList?.toList() ?? <T>[];
    items.insert(index, item);
    itemList = items;
  }

  void updateItemList<T>(List<T> Function(List<dynamic> items) updater) {
    itemList = updater(itemList?.toList() ?? []);
  }

  void updateItems<T>(T Function(int index, T item) map) {
    final items = itemList;
    if (items == null || items.isEmpty) {
      return;
    }

    itemList = List<T>.generate(
      items.length,
      (index) => map(index, items[index]),
    );
  }
}
