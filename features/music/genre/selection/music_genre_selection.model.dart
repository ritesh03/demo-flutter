import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

class MusicGenreSelectionModel with ChangeNotifier {
  MusicGenreSelectionModel({
    required List<MusicGenre> selectedGenres,
  }) : _selectedGenres = selectedGenres;

  List<MusicGenre> _selectedGenres;

  Result<List<MusicGenre>>? _genresResult;
  Result<List<MusicGenre>>? _genreSearchResult;

  Result<List<MusicGenre>>? get genresResult =>
      _genreSearchResult ?? _genresResult;

  List<MusicGenre> get selectedGenres => _selectedGenres;

  void fetchMusicGenres() async {
    if (_genresResult != null) {
      _genresResult = null;
      notifyListeners();
    }

    _genresResult = await locator<KwotData>().musicRepository.fetchGenres();
    if (_appliedSearchQuery != null) {
      _search();
    }

    notifyListeners();
  }

  void _search() {
    final searchQuery = _appliedSearchQuery?.toLowerCase();
    if (searchQuery == null || searchQuery.isEmpty) {
      _genreSearchResult = null;
      notifyListeners();
      return;
    }

    final result = _genresResult;
    if (result == null || !result.isSuccess()) {
      _genreSearchResult = null;
      notifyListeners();
      return;
    }

    final filteredGenres = result.data().where((genre) {
      return genre.title.toLowerCase().contains(searchQuery);
    }).toList();
    _genreSearchResult = Result.success(filteredGenres);
    notifyListeners();
  }

  bool canClearSelection() {
    final result = _genresResult;
    if (result == null || !result.isSuccess()) {
      return false;
    }

    // 0: default genre
    // 1/1+: genres
    return ((result.peek()?.length) ?? 0) > 1;
  }

  bool canApplySelection() {
    return canClearSelection();
  }

  /*
   * SEARCH QUERY
   */

  String? _appliedSearchQuery;

  String? get appliedSearchQuery => _appliedSearchQuery;

  void updateSearchQuery(String text) {
    if (_appliedSearchQuery != text) {
      _appliedSearchQuery = text;
      _search();
    }
  }

  void clearSearchQuery() {
    if (_appliedSearchQuery != null) {
      _appliedSearchQuery = null;
      _search();
    }
  }

  /*
   * GENRE SELECTION
   */

  bool isGenreSelected({required String id}) {
    return _selectedGenres.any((genre) => genre.id == id);
  }

  void toggleGenreSelection(MusicGenre genre) {
    final genres = _selectedGenres.toList();
    if (isGenreSelected(id: genre.id)) {
      genres.removeWhere((element) => (element.id == genre.id));
    } else {
      genres.add(genre);
    }

    _selectedGenres = genres;
    notifyListeners();
  }
}
