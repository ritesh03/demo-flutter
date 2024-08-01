import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotdata/models/artist/subscription.artist.model.dart' as subscription;
import 'package:kwotdata/models/artist/subscription.plan.artist.dart';
import 'package:kwotdata/models/videos/video.dart';
import 'package:kwotmusic/events/events.dart';
import 'dart:developer' as dev;

import '../../../components/widgets/blocking_progress.dialog.dart';

class ArtistPageArgs {
  ArtistPageArgs({
    required this.id,
    this.name,
    this.thumbnail,
  });

  ArtistPageArgs.object({required Artist artist})
      : id = artist.id,
        name = artist.name,
        thumbnail = artist.thumbnail;

  final String id;
  final String? name;
  final String? thumbnail;
}

class ArtistModel with ChangeNotifier {
  //=
  final ArtistPageArgs _artistArgs;


  async.CancelableOperation<Result<Artist>>? _artistOp;
  async.CancelableOperation<Result<List<subscription.SubscriptionArtistPlanModel>>>? _subscription;
  async.CancelableOperation<Result<Plan>>? _buySubscription;
  async.CancelableOperation<Result<Profile>>? _profileOp;
  async.CancelableOperation<Result<Plan>>? _leaveFanClub;
  async.CancelableOperation<Result<BillingDetail>>? _billingDetailOp;
  Result<BillingDetail>? billingDetailResult;
  Result<Plan>? leaveFanClubResult;
  Result<Profile>? profileResult;
  Result<Artist>? artistResult;
  Result<Plan>? planResult;
  String? planId;
  int? toBuyPlanToken;
  String? planName;

  Result<List<subscription.SubscriptionArtistPlanModel>>? subscriptionResult;

  ArtistPageContentType _selectedPageContentType =
      ArtistPageContentType.profile;
  late final StreamSubscription _eventsSubscription;

  ArtistModel({
    required ArtistPageArgs args,
  }) : _artistArgs = args {
    _eventsSubscription = _listenToEvents();
  }

  void init() {
    fetchArtist().then((value) {
      fetchSubscription();
    });
   fetchProfile();
   fetchBillingDetail();
  }

  @override
  void dispose() {
    _eventsSubscription.cancel();
    _artistOp?.cancel();
   _leaveFanClub !=null? _leaveFanClub!.cancel():null;
    _subscription !=null?_subscription!.cancel():null;
    _profileOp!.cancel();
    _billingDetailOp?.cancel();
    super.dispose();
  }

  Artist? get artist => artistResult?.peek();

  bool showTabBar = false;
  bool isArtist = false;

  bool get canShowOptions => (artist != null);

  bool get canShowFollowOption => (artist != null);

///Here we are checking weather the user has fan of artist and artist has fan club membership
  bool get canJoinArtistFanClub {
    final artist = this.artist;
    if (artist == null) return false;
    if(artist.hasFanClubs){
      if(!artist.isUserAFan){
        return true;
      }else{
        return false;
      }
    }
    return false;
   // return artist.hasFanClubs && artist.isUserAFan;
  }
  /// Here we are checking the user is fan of the artist to show fan club step bar
  bool get showFanClub{
    final artist = this.artist;
    if (artist == null) return false;
      if(artist.isUserAFan){
        return true;
      }else{
        return false;
      }
  }

  ArtistPageContentType get selectedPageContentType {
    if (hasJoinedFanClub) {
      return _selectedPageContentType;
    }

    return ArtistPageContentType.profile;
  }

  bool get hasJoinedFanClub {
    final artist = this.artist;
    if (artist == null) return false;
    return artist.hasFanClubs && artist.isUserAFan;
  }

  bool get canShowTipOption => (artist != null && artist!.canBeTipped);

  String? get profilePhotoPath {
    if (artist != null) {
      return artist?.thumbnail;
    }

    return _artistArgs.thumbnail;
  }

  String? get coverPhotoPath => profilePhotoPath;

  List<Feed>? get feeds => artist?.feeds;

  int get followerCount => artist?.followerCount ?? 0;

  int get followingCount => artist?.followingCount ?? 0;

  bool get isFollowed => artist?.isFollowed ?? false;

  String? get name => artist?.name ?? _artistArgs.name;
///Fetch artist data
  Future<void> fetchArtist() async {
    try {
      // Cancel current operation (if any)
      _artistOp?.cancel();

      if (artistResult != null) {
        artistResult = null;
        notifyListeners();
      }

      dev.log("artist result :::  ${_artistArgs.id}");
      // Create Request
      final request = ArtistRequest(id: _artistArgs.id, isFanClub: isArtist);
      _artistOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.fetchArtist(request));

      // Wait for result
      artistResult = await _artistOp?.value;
     // dev.log("artist result :::  ${artistResult}");
    } catch (error) {
      artistResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

///fetch user billing details
  Future<void> fetchBillingDetail() async {
    try {
      // Cancel current operation (if any)
      _billingDetailOp?.cancel();

      if (billingDetailResult != null) {
        billingDetailResult = null;
        notifyListeners();
      }

      // Create operation
      final billingDetailOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchBillingDetail());
      _billingDetailOp = billingDetailOp;

      // Listen for result
      billingDetailResult = await billingDetailOp.value;
    } catch (error) {
      billingDetailResult = Result.error(error.toString());
    }

    notifyListeners();
  }

///To buy subscription plan for fan club
  Future<bool> buySubscription() async {
    try {
      // Cancel current operation (if any)
      _buySubscription?.cancel();

      if (planResult != null) {
        planResult = null;
        notifyListeners();
      }
      // Create Request
      _buySubscription = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.buyArtistPlan(planId??""));

      // Wait for result
      planResult = await _buySubscription?.value;


      if(planResult!.isSuccess()){
        return true;
      }
      else{
        return false;
      }
    } catch (error) {
      planResult = Result.error("Error: $error");
      return false;
    }
    notifyListeners();
  }
/// Fetch user token to purchase plan
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
    notifyListeners();
  }
///Fetch subscription plan for an artist on the base of artist ID
  Future<void> fetchSubscription() async {
    try {
      // Cancel current operation (if any)
      _subscription?.cancel();
      if (subscriptionResult != null) {
        subscriptionResult = null;
        notifyListeners();
      }
      // Create Request
      _subscription = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.fetchSubscriptionPlans(artist!.id));
      // Wait for result
      subscriptionResult = await _subscription!.value ;
    } catch (error) {
      artistResult = Result.error("Error: $error");
    }
    notifyListeners();
  }
///Leave the fan club
  Future<bool> leaveFanClub(context,) async {
    try {
      showBlockingProgressDialog(context);
      // Cancel current operation (if any)
      _leaveFanClub?.cancel();

      if (leaveFanClubResult != null) {
        leaveFanClubResult = null;
        notifyListeners();
      }
      // Create Request
      _leaveFanClub = async.CancelableOperation.fromFuture(
          locator<KwotData>().artistsRepository.leaveFanClub());
      // Wait for result
      leaveFanClubResult = await _leaveFanClub?.value;
      if (leaveFanClubResult != null) {
        hideBlockingProgressDialog(context);
      }
      if (leaveFanClubResult!.isSuccess()) {
        return true;
      }
      else {
        return false;
      }
    } catch (error) {
      hideBlockingProgressDialog(context);
      leaveFanClubResult = Result.error("Error: $error");
      return false;
    }
  }

  /*
   * SET PAGE CONTENT TYPE TO DISPLAY
   */

  void setSelectedPageContentType(ArtistPageContentType type) {
    if (_selectedPageContentType == type) {
      return;
    }

    if (!hasJoinedFanClub) {
      return;
    }

    _selectedPageContentType = type;
    notifyListeners();
  }






  /*
   * EVENT: ArtistBlockUpdatedEvent, ArtistFollowUpdatedEvent
   */

  StreamSubscription _listenToEvents() {
    return eventBus.on().listen((event) {
      if (event is ArtistFollowUpdatedEvent) {
        return _handleArtistFollowEvent(event);
      }
    });
  }

  void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
    final artist = this.artist;
    if (artist == null || artist.id != event.artistId) return;

    artistResult = Result.success(event.update(artist));
    notifyListeners();
  }
}

enum ArtistPageContentType { profile, fanPage }
