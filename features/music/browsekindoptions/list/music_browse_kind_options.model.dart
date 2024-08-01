import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

import 'music_browse_kind_options.args.dart';

class MusicBrowseKindOptionsModel with ChangeNotifier {
  //=
  final Feed<MusicBrowseKindOption> _initialFeed;
  late MusicBrowseKindOptionsFilter filter;

  MusicBrowseKindOptionsModel({
    required MusicBrowseKindOptionsArgs args,
  }) : _initialFeed = args.availableFeed {
    filter = MusicBrowseKindOptionsFilter(query: null);
  }

  async.CancelableOperation<Result<List<MusicBrowseKindOption>>>?
      _browseKindOptionsOp;
  Result<List<MusicBrowseKindOption>>? _browseKindOptionsResult;
  Result<List<MusicBrowseKindOption>>? _filteredBrowseKindOptionsResult;

  void init() {
    fetchMusicBrowseKindOptions();
  }

  Result<List<MusicBrowseKindOption>>? get browseKindOptionsResult =>
      _filteredBrowseKindOptionsResult ?? _browseKindOptionsResult;

  List<MusicBrowseKindOption> get _browseKindOptions =>
      _browseKindOptionsResult?.peek() ?? [];

  String? get pageTitle => _initialFeed.pageTitle;

  @override
  void dispose() {
    _browseKindOptionsOp?.cancel();
    super.dispose();
  }

  /*
   * API: Music Browse Kind Options List
   */

  Future<void> fetchMusicBrowseKindOptions({
    bool forceRefresh = false,
  }) async {
    try {
      // Cancel current operation (if any)
      _browseKindOptionsOp?.cancel();
      _filteredBrowseKindOptionsResult = null;

      if (!forceRefresh &&
          _browseKindOptionsResult != null &&
          _browseKindOptions.isEmpty) {
        _browseKindOptionsResult = null;
        notifyListeners();
      }

      if (forceRefresh || _browseKindOptions.isEmpty) {
        // Create Request
        final request = MusicBrowseKindOptionsRequest(
          kindId: _initialFeed.items.first.kindId,
          feedId: _initialFeed.id,
        );
        _browseKindOptionsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().musicRepository.fetchBrowseKindOptions(request),
        );

        // Listen for result
        _browseKindOptionsResult = await _browseKindOptionsOp?.value;
      }

      final updatedBrowseKindOptions = _browseKindOptions;
      if (updatedBrowseKindOptions.isNotEmpty) {
        if (filter.hasSearchQuery) {
          final query = filter.query!;
          _filteredBrowseKindOptionsResult = Result.success(
            updatedBrowseKindOptions.where((option) {
              return option.title.toLowerCase().contains(query.toLowerCase());
            }).toList(),
          );
        }
      }
    } catch (error) {
      _filteredBrowseKindOptionsResult = null;
      _browseKindOptionsResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  Future<void> refresh() {
    return fetchMusicBrowseKindOptions(forceRefresh: true);
  }

  /*
   * Search Query
   */

  String? get appliedSearchQuery => filter.query;

  void updateSearchQuery(String text) {
    if (appliedSearchQuery != text) {
      filter = filter.copyWithQuery(query: text);
      fetchMusicBrowseKindOptions();
    }
  }

  void clearSearchQuery() {
    if (appliedSearchQuery != null) {
      filter = filter.copyWithQuery(query: null);
      fetchMusicBrowseKindOptions();
    }
  }
}
