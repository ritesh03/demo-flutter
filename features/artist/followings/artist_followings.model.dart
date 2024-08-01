import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/followings/followings.model.dart';

class ArtistFollowingsPageArgs {
  ArtistFollowingsPageArgs({
    required this.artistId,
    this.artistName,
  });

  final String artistId;
  final String? artistName;
}

class ArtistFollowingsModel extends FollowingsModel {
  //=

  ArtistFollowingsModel({
    required ArtistFollowingsPageArgs args,
  }) : super(userId: args.artistId, userName: args.artistName);

  @override
  Future<Result<ListPage<User>>> onCreateFollowingsRequest({
    required String userId,
    required String? query,
    required int page,
  }) {
    final request = ArtistFollowingsRequest(id: userId, query: query, page: page);
    return locator<KwotData>().artistsRepository.fetchFollowings(request);
  }
}
