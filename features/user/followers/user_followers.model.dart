import 'dart:async';

import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/followers/followers.model.dart';

class UserFollowersPageArgs {
  UserFollowersPageArgs({
    required this.userId,
    this.userName,
  });

  final String userId;
  final String? userName;
}

class UserFollowersModel extends FollowersModel {
  //=

  UserFollowersModel({
    required UserFollowersPageArgs args,
  }) : super(userId: args.userId, userName: args.userName);

  @override
  Future<Result<ListPage<User>>> onCreateFollowersRequest({
    required String userId,
    required String? query,
    required int page,
  }) {
    final request = UserFollowersRequest(id: userId, query: query, page: page);
    return locator<KwotData>().usersRepository.fetchFollowers(request);
  }
}
