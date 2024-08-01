import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';

import 'playlists_use_case.dart';

class FeedPlaylistsUseCase implements PlaylistsUseCase {
  FeedPlaylistsUseCase({
    required this.feed,
  });

  final Feed<Playlist> feed;

  ItemListViewMode get itemListViewMode => createViewModeFromFeed(feed);

  bool get canSearchInFeed => feed.searchable;

  @override
  String? getPageTitle(
    BuildContext context, {
    required bool hasSearchQuery,
  }) {
    if (!canSearchInFeed && hasSearchQuery) {
      return null;
    }

    return feed.pageTitle;
  }

  @override
  Future<Result<ListPage<Playlist>>> fetchPlaylists({
    required int page,
    String? query,
  }) {
    final feedId = (!canSearchInFeed && query != null) ? null : feed.id;
    final request = PlaylistsRequest(feedId: feedId, page: page, query: query);
    return locator<KwotData>().playlistsRepository.fetchPlaylists(request);
  }
}
