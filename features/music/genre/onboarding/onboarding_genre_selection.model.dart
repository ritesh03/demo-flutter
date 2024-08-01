import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';

class OnboardingGenreSelectionModel with ChangeNotifier {
  async.CancelableOperation<Result<List<MusicGenre>>>? _genresOp;
  Result<List<ChipItem>>? _genreChipsResult;

  final Set<String> _selectedGenres = {};
  async.CancelableOperation<Result>? _updateGenresOp;

  void init() {
    fetchMusicGenres();
  }

  Result<List<ChipItem>>? get genreChipsResult => _genreChipsResult;

  int get selectedGenreCount => _selectedGenres.length;

  @override
  void dispose() {
    _genresOp?.cancel();
    _updateGenresOp?.cancel();
    super.dispose();
  }

  void onGenreSelectionToggled(String id) {
    if (_selectedGenres.contains(id)) {
      _selectedGenres.remove(id);
    } else {
      _selectedGenres.add(id);
    }
    notifyListeners();
  }

  /*
   * API: Music Genre List
   */

  Future<void> fetchMusicGenres() async {
    try {
      // Cancel current operation (if any)
      _genresOp?.cancel();

      if (_genreChipsResult != null) {
        _genreChipsResult = null;
        notifyListeners();
      }

      // Create Request
      _genresOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchOnboardingGenres(),
      );

      // Listen for result
      final result = await _genresOp?.value;
      _genreChipsResult = result?.map((genres) {
        return genres.map((genre) {
          return ChipItem(
            identifier: genre.id,
            selected: false,
            text: genre.title,
          );
        }).toList();
      });
    } catch (error) {
      _genreChipsResult = Result.error(error.toString());
    }

    notifyListeners();
  }

  /*
   * API: Set Favorite Music Genres
   */

  Future<Result> updateFavoriteMusicGenres() async {
    try {
      // Cancel current operation (if any)
      _updateGenresOp?.cancel();

      // Create Request
      final request = UpdateOnboardingGenresRequest(
        genreIds: _selectedGenres.toList(),
      );
      _updateGenresOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.updateOnboardingGenres(request),
      );
      return await _updateGenresOp!.value;
    } catch (error) {
      return Result.error("Error: $error");
    }
  }
}
