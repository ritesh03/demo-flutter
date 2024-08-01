import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/followers/followers.model.dart';

class ArtistFollowersPageArgs {
  ArtistFollowersPageArgs({
    required this.artistId,
    this.artistName,
  });

  final String artistId;
  final String? artistName;
}

class ArtistFollowersModel extends FollowersModel {
  //=

  ArtistFollowersModel({
    required ArtistFollowersPageArgs args,
  }) : super(userId: args.artistId, userName: args.artistName);

  @override
  Future<Result<ListPage<User>>> onCreateFollowersRequest({
    required String userId,
    required String? query,
    required int page,
  }) {
    final request = ArtistFollowersRequest(id: userId, query: query, page: page);
    return locator<KwotData>().artistsRepository.fetchFollowers(request);
  }
}
