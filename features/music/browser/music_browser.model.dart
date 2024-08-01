import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list.model.dart';
import 'package:wrapped_infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'music_browser.args.dart';

class MusicBrowserModel with ChangeNotifier, ItemListModel<Feed> {
  //=
  late BrowseMusicFilter filter;

  MusicBrowserModel({
    required MusicBrowserArgs args,
  }) {
    final browseKindOptionId = args.browseKindOptionId;
    filter = BrowseMusicFilter(
      browseKindId: args.browseKindId,
      browseKindOptionIds:
          (browseKindOptionId != null) ? [browseKindOptionId] : null,
      genres: null,
      query: null,
    );
  }

  async.CancelableOperation<Result<MusicBrowseKindWithOptions>>?
      _browseKindAndOptionsOp;
  Result<MusicBrowseKindWithOptions>? _browseKindAndOptionsResult;

  async.CancelableOperation<Result<ListPage<Feed>>>? _feedsOp;
  final _feedsController = PagingController<int, Feed>(firstPageKey: 1);

  void init() {
    fetchBrowseKindAndOptions();
    _feedsController.addPageRequestListener((pageKey) {
      _browseMusic(pageKey);
    });
  }

  Result<MusicBrowseKindWithOptions>? get browseKindAndOptionsResult =>
      _browseKindAndOptionsResult;

  MusicBrowseKind? get browseKind =>
      _browseKindAndOptionsResult?.peek()?.browseKind;

  List<MusicBrowseKindOption> get browseKindOptions =>
      _browseKindAndOptionsResult?.peek()?.browseKindOptions ?? [];

  List<MusicBrowseKindOption> get selectedBrowseKindOptions {
    if (!filter.hasBrowseKindOptions) return [];

    return browseKindOptions.where((option) {
      return filter.browseKindOptionIds?.contains(option.id) ?? false;
    }).toList();
  }

  bool get filtered => filter.hasGenres;

  List<MusicGenre> get selectedGenres => filter.genres ?? [];

  String? get appliedSearchQuery => filter.query;

  @override
  void dispose() {
    _browseKindAndOptionsOp?.cancel();
    _feedsOp?.cancel();
    _feedsController.dispose();
    super.dispose();
  }

  /*
   * API: Load MusicBrowseKind & MusicBrowseKindOptions
   */

  Future<void> fetchBrowseKindAndOptions() async {
    try {
      // Cancel current operation (if any)
      _browseKindAndOptionsOp?.cancel();

      if (_browseKindAndOptionsResult != null) {
        _browseKindAndOptionsResult = null;
        notifyListeners();
      }

      /// Fetch browse kind and its options by kind-id
      final request = MusicBrowseKindRequest(id: filter.browseKindId);
      _browseKindAndOptionsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().musicRepository.fetchBrowseKindWithOptions(request),
      );

      _browseKindAndOptionsResult = await _browseKindAndOptionsOp!.value;
    } catch (error) {
      _browseKindAndOptionsResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  /*
   * API: Music Feeds List
   */

  Future<void> _browseMusic(int pageKey) async {
    try {
      // Cancel current operation (if any)
      _feedsOp?.cancel();

      // Create Request
      final request = BrowseMusicRequest(
        browseKindId: filter.browseKindId,
        browseKindOptionIds: filter.browseKindOptionIds,
        genres: filter.genres,
        page: pageKey,
        query: filter.query,
      );
      _feedsOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().musicRepository.browseMusic(request),
        onCancel: () {
          _feedsController.error = "Cancelled.";
        },
      );

      // Listen for result
      _feedsOp?.value.then((result) {
        if (!result.isSuccess()) {
          _feedsController.error = result.error();
          return;
        }

        final page = result.data();
        final currentItemCount = _feedsController.itemList?.length ?? 0;
        final isLastPage = page.isLastPage(currentItemCount);
        if (isLastPage) {
          if(page.items != null) {
            _feedsController.appendLastPage(page.items!);
          }
        } else {
          final nextPageKey = pageKey + 1;
          if(page.items != null) {
            _feedsController.appendPage(page.items!, nextPageKey);
          }
        }
      });
    } catch (error) {
      _feedsController.error = error;
    }
  }

  /*
   * Search Query
   */

  void updateSearchQuery(String text) {
    if (appliedSearchQuery != text) {
      filter = filter.copyWithQuery(query: text);
      _feedsOp?.cancel();
      _feedsController.refresh();
      notifyListeners();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      _feedsOp?.cancel();
      _feedsController.refresh();
      notifyListeners();
    }
  }

  /*
   * Music Browse Kind filter
   */

  void updateSelectedBrowseKindOptionsWith(MusicBrowseKindOption? option) {
    if (option == null) {
      return _setSelectedBrowseKindOptions(null);
    }

    final selectedBrowseKindOptionIds =
        filter.browseKindOptionIds?.toList() ?? <String>[];
    if (selectedBrowseKindOptionIds.contains(option.id)) {
      selectedBrowseKindOptionIds.remove(option.id);
    } else {
      selectedBrowseKindOptionIds.add(option.id);
    }

    _setSelectedBrowseKindOptions(selectedBrowseKindOptionIds);
  }

  void _setSelectedBrowseKindOptions(List<String>? optionIds) {
    filter = filter.copyWithBrowseKindOptions(browseKindOptionIds: optionIds);
    _feedsOp?.cancel();
    _feedsController.refresh();
  }

  /*
   * Genre Selection
   */

  void setSelectedGenres(List<MusicGenre> genres) {
    filter = filter.copyWithGenres(genres: genres);
    _feedsController.refresh();
    notifyListeners();
  }

  /*
   * ItemListModel<Feed>
   */

  @override
  PagingController<int, Feed> controller() => _feedsController;

  @override
  void refresh({
    required bool resetPageKey,
    bool isForceRefresh = false,
  }) {
    _feedsOp?.cancel();

    if (resetPageKey) {
      _feedsController.refresh();
    } else {
      // TODO: @Github/EdsonBueno/infinite_scroll_pagination/issues/106
      _feedsController.retryLastFailedRequest();
    }
  }
}
