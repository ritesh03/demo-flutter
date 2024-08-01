import 'package:kwotdata/kwotdata.dart';

import 'events.dart';

class UserBlockUpdatedEvent extends Event {
  final User user;

  UserBlockUpdatedEvent({
    required this.user,
  }) : super(id: user.id);

  String get userId => user.id;

  bool get blocked => user.isBlocked;

  User update(User targetUser) {
    if (targetUser.id != user.id) return targetUser;
    return targetUser.copyWith(
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      firstName: user.firstName,
      isBlocked: user.isBlocked,
      isFollowed: user.isFollowed,
      lastName: user.lastName,
      playlistCount: user.playlistCount,
      thumbnail: user.thumbnail,
    );
  }
}

class UserFollowUpdatedEvent extends Event {
  final String userId;
  final bool followed;
  final int followers;

  UserFollowUpdatedEvent({
    required this.userId,
    required this.followed,
    required this.followers,
  }) : super(id: userId);

  User update(User user) {
    if (user.id != userId) return user;
    return user.copyWith(
      isFollowed: followed,
      followerCount: followers,
    );
  }
}
