import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';

abstract class PlaylistsUseCase {
  String? getPageTitle(
    BuildContext context, {
    required bool hasSearchQuery,
  });

  Future<Result<ListPage<Playlist>>> fetchPlaylists({
    required int page,
    String? query,
  });
}
