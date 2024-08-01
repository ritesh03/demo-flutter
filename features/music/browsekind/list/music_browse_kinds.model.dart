import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

import 'music_browse_kinds.args.dart';

class MusicBrowseKindsModel with ChangeNotifier {
  //=
  final Feed<MusicBrowseKind> _initialFeed;
  late MusicBrowseKindsFilter filter;

  MusicBrowseKindsModel({
    required MusicBrowseKindsArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = MusicBrowseKindsFilter(query: null);
  }

  async.CancelableOperation<Result<List<MusicBrowseKind>>>? _browseKindsOp;
  Result<List<MusicBrowseKind>>? _browseKindsResult;
  Result<List<MusicBrowseKind>>? _filteredBrowseKindsResult;

  void init() {
    fetchMusicBrowseKinds();
  }

  Result<List<MusicBrowseKind>>? get browseKindsResult =>
      _filteredBrowseKindsResult ?? _browseKindsResult;

  List<MusicBrowseKind> get _browseKinds => _browseKindsResult?.peek() ?? [];

  String? get pageTitle => _initialFeed.pageTitle;

  @override
  void dispose() {
    _browseKindsOp?.cancel();
    super.dispose();
  }

  /*
   * API: Music Browse Kinds List
   */

  Future<void> fetchMusicBrowseKinds({
    bool forceRefresh = false,
  }) async {
    try {
      // Cancel current operation (if any)
      _browseKindsOp?.cancel();
      _filteredBrowseKindsResult = null;

      if (!forceRefresh && _browseKindsResult != null && _browseKinds.isEmpty) {
        _browseKindsResult = null;
        notifyListeners();
      }

      if (forceRefresh || _browseKinds.isEmpty) {
        // Create Request
        final request = MusicBrowseKindsRequest(feedId: _initialFeed.id);
        _browseKindsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().musicRepository.fetchBrowseKinds(request),
        );

        // Listen for result
        _browseKindsResult = await _browseKindsOp?.value;
      }

      final updatedBrowseKinds = _browseKinds;
      if (updatedBrowseKinds.isNotEmpty) {
        if (filter.hasSearchQuery) {
          final query = filter.query!;
          _filteredBrowseKindsResult = Result.success(
            updatedBrowseKinds.where((kind) {
              return kind.title.toLowerCase().contains(query.toLowerCase());
            }).toList(),
          );
        }
      }
    } catch (error) {
      _filteredBrowseKindsResult = null;
      _browseKindsResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  Future<void> refresh() {
    return fetchMusicBrowseKinds(forceRefresh: true);
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => filter.query;

  void updateSearchQuery(String text) {
    if (appliedSearchQuery != text) {
      filter = filter.copyWithQuery(query: text);
      fetchMusicBrowseKinds();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      fetchMusicBrowseKinds();
    }
  }
}
