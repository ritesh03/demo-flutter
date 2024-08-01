import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import 'playlists_use_case.dart';

class UserPlaylistsUseCase implements PlaylistsUseCase {
  UserPlaylistsUseCase({
    required this.user,
  });

  final User user;

  @override
  String? getPageTitle(
    BuildContext context, {
    required bool hasSearchQuery,
  }) {
    final currentUserId = locator<KwotData>().storageRepository.getUserId();
    if (currentUserId == user.id) {
      return LocaleResources.of(context).yourPlaylists;
    } else {
      return LocaleResources.of(context).playlistsOfUserFormat(user.firstName);
    }
  }

  @override
  Future<Result<ListPage<Playlist>>> fetchPlaylists({
    required int page,
    String? query,
  }) {
    final request = PlaylistsRequest(userId: user.id, page: page, query: query);
    return locator<KwotData>().playlistsRepository.fetchPlaylists(request);
  }
}
