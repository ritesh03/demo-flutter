import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/followings/followings.model.dart';

class UserFollowingsPageArgs {
  UserFollowingsPageArgs({
    required this.userId,
    this.userName,
  });

  final String userId;
  final String? userName;
}

class UserFollowingsModel extends FollowingsModel {
  //=

  UserFollowingsModel({
    required UserFollowingsPageArgs args,
  }) : super(userId: args.userId, userName: args.userName);

  @override
  Future<Result<ListPage<User>>> onCreateFollowingsRequest({
    required String userId,
    required String? query,
    required int page,
  }) {
    final request = UserFollowingsRequest(id: userId, query: query, page: page);
    return locator<KwotData>().usersRepository.fetchFollowings(request);
  }
}
