import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class ItemListModel<ITEM> {
  //=
  PagingController<int, ITEM> controller();

  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  });
}
