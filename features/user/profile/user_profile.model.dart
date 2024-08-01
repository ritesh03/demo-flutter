import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class UserProfileArgs {
  UserProfileArgs({
    required this.id,
    this.name,
    this.thumbnail,
  });

  final String id;
  final String? name;
  final String? thumbnail;
}

class UserProfileModel with ChangeNotifier {
  //=
  final UserProfileArgs args;

  async.CancelableOperation<Result<User>>? _userProfileOp;
  Result<User>? userResult;

  late final StreamSubscription _eventsSubscription;

  UserProfileModel({
    required this.args,
  }) {
    _eventsSubscription = _listenToEvents();
  }

  void init() async {
    fetchUserProfile();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _userProfileOp?.cancel();
    super.dispose();
  }

  User? get user => userResult?.peek();

  bool get canShowOptions => (user != null && !user!.isBlocked);

  bool get canShowFollowOption =>
      (user != null && !user!.isBlocked && !isSelfProfile);

  bool get canShowUnblockOption =>
      (user != null && user!.isBlocked && !isSelfProfile);

  bool get isSelfProfile {
    final user = this.user;
    if (user == null) return false;
    return user.id == locator<KwotData>().storageRepository.getUserId();
  }

  String? get profilePhotoPath {
    if (user != null) {
      return user?.thumbnail;
    }

    return args.thumbnail;
  }

  String? get coverPhotoPath => profilePhotoPath;

  List<Feed>? get feeds {
    if (user == null) return null;
    if (user!.isBlocked) return null;
    return user!.feeds;
  }

  int get followerCount => user?.followerCount ?? 0;

  int get followingCount => user?.followingCount ?? 0;

  int get playlistCount => user?.playlistCount ?? 0;

  bool get isFollowed => user?.isFollowed ?? false;

  bool get isBlocked => user?.isBlocked ?? false;

  String? get name => user?.name ?? args.name;

  Future<void> fetchUserProfile() async {
    try {
      // Cancel current operation (if any)
      _userProfileOp?.cancel();

      if (userResult != null) {
        userResult = null;
        notifyListeners();
      }

      // Create Request
      final request = UserProfileRequest(id: args.id);
      _userProfileOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().usersRepository.fetchUserProfile(request));

      // Wait for result
      userResult = await _userProfileOp?.value;
    } catch (error) {
      userResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  /*
   * EVENT: UserBlockUpdatedEvent, UserFollowUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is UserBlockUpdatedEvent) {
        return _handleUserBlockEvent(event);
      }
      if (event is UserFollowUpdatedEvent) {
        return _handleUserFollowEvent(event);
      }
    });
  }

  void _handleUserBlockEvent(UserBlockUpdatedEvent event) {
    final user = this.user;
    if (user == null || user.id != event.userId) return;

    userResult = Result.success(event.update(user));
    notifyListeners();
  }

  void _handleUserFollowEvent(UserFollowUpdatedEvent event) {
    final user = this.user;
    if (user == null || user.id != event.userId) return;

    userResult = Result.success(event.update(user));
    notifyListeners();
  }
}
