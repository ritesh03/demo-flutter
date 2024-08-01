import 'dart:async';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/events/events.dart';

class AccountHomeModel with ChangeNotifier {
  //=
  async.CancelableOperation<Result<Profile>>? _profileOp;
  Result<Profile>? profileResult;

  StreamSubscription? _eventsSubscription;

  AccountHomeModel() {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    fetchProfile();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _profileOp?.cancel();
    super.dispose();
  }

  Profile? get profile => profileResult?.peek();

  String? get profilePhotoPath => profile?.profilePhoto;

  String? get coverPhotoPath => profilePhotoPath;

  String? get name => profile?.name;

  Future<void> fetchProfile() async {
    // Cancel current operation (if any)
    _profileOp?.cancel();

    if (profileResult != null) {
      profileResult = null;
      notifyListeners();
    }

    // Create Request
    _profileOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.fetchProfile());

    // Wait for result
    profileResult = await _profileOp?.value;
    print(profileResult);
    notifyListeners();
  }

  void updateProfile(Profile updatedProfile) {
    profileResult = Result.success(updatedProfile);
    notifyListeners();
  }

  /*
   * EVENT: ProfileUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ProfileUpdatedEvent) {
        return _handleProfileUpdatedEvent(event);
      }
    });
  }

  void _handleProfileUpdatedEvent(ProfileUpdatedEvent event) {
    final profile = this.profile;
    if (profile == null) return;

    profileResult = Result.success(event.update(profile));
    notifyListeners();
  }
}
