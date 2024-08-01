import 'dart:async';
import 'package:async/async.dart' as async;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/result.dart';
import 'package:kwotdata/models/videos/video.dart';
// import 'package:kwotmusic/features/videos/detail/videos_page_interface.dart';

import '../../../events/events.dart';

class VideosDetailArgs {

  String title;

  String url;

  String addedAt;

  String image;

  String id;


  String duration;

  String views;

  VideosDetailArgs({
    required this.url,
    required this.title,
    required this.addedAt,
    required this.image,
    required this.id,
    required this.duration,
    required this.views,
  });

}




/*
class VideosDetailModel with ChangeNotifier {
  //=
  final String _receivedSkitId;
  final String? _receivedSkitTitle;
  final String? _receivedSkitThumbnail;
  final VideosDetailArgs _videosDetailArgs; 
  String? _subtitleText;

 // late final StreamSubscription _eventsSubscription;

 // VideosPageInterface? _pageInterface;

 // VideosPageInterface? get pageInterface => _pageInterface;

  VideosDetailModel({
    required VideosDetailArgs args,
  })  : _receivedSkitId = args.id,
        _receivedSkitTitle = args.title,
        _videosDetailArgs = args,
        _receivedSkitThumbnail = args.image {
    //_eventsSubscription = _listenToEvents();
  }

  async.CancelableOperation<Result<Videos>>? _videosOp;
  Result<Videos>? _videosResult;

  Function(Videos videos)? onVideosAvailable;

  void init({required Function(Videos videos) onVideosAvailable}) {
    this.onVideosAvailable = onVideosAvailable;
    fetchVideos();
  }

  @override
  void dispose() {
    //_eventsSubscription.cancel();
   // _pageInterface?.dispose();

    _videosOp?.cancel();
    super.dispose();
  }

  Result<Videos>? get videosResult => _videosResult;

  Videos? get video => _videosResult?.peek();

  String? get title => video?.title ?? _receivedSkitTitle;

  String? get subtitle => _subtitleText;

  String? get thumbnail => video?.image ?? _receivedSkitThumbnail;

*/
/*
  void updateSubtitle(BuildContext context) {
    final skit = this.skit;
    if (skit == null) return;

    final localization = LocaleResources.of(context);

    /// How many views? e.g. 5.7k views
    final viewsText =
    localization.integerViewCountFormat(skit.views, skit.views.prettyCount);

    /// When did it start? e.g. 4 minutes ago
    final createdAt = skit.createdAt;
    final dateTimeText = timeago.format(createdAt);

    _subtitleText = "$viewsText · $dateTimeText";
    pageInterface?.updateSubtitle(subtitle);
  }
*//*


 

  Future<void> fetchVideos() async {

    Videos videos = Videos(title: _videosDetailArgs.title,
        url: _videosDetailArgs.url,
        addedAt: _videosDetailArgs.addedAt,
        duration: _videosDetailArgs.duration,
        views:_videosDetailArgs.views,
        image: _videosDetailArgs.image,
        id: _videosDetailArgs.id);
    
    if (videos != null) {
    //  _pageInterface = VideosPageInterface(videos: videos);
      onVideosAvailable?.call(videos);
    }
    //notifyListeners();
  }

  */
/*
   * EVENT:
   *  ArtistBlockUpdatedEvent,
   *  ArtistFollowUpdatedEvent,
   *  SkitLikeUpdatedEvent,
   *//*


  // StreamSubscription _listenToEvents() {
  //   return eventBus.on().listen((event) {
  //     if (event is ArtistFollowUpdatedEvent) {
  //       return _handleArtistFollowEvent(event);
  //     }
  //     if (event is SkitLikeUpdatedEvent) {
  //       return _handleSkitLikeEvent(event);
  //     }
  //   });
  // }
  //
  // void _handleArtistFollowEvent(ArtistFollowUpdatedEvent event) {
  //   final skit = this.skit;
  //   if (skit == null || skit.artist.id != event.artistId) return;
  //
  //   final updatedArtist = event.update(skit.artist);
  //   final updatedSkit = skit.copyWith(artist: updatedArtist);
  //   _videosResult = Result.success(updatedSkit);
  //   notifyListeners();
  // }
  //
  // void _handleSkitLikeEvent(SkitLikeUpdatedEvent event) {
  //   final skit = this.;
  //   if (skit == null || skit.id != event.skitId) return;
  //
  //   _videosResult = Result.success(event.update(skit));
  //   notifyListeners();
  // }
}*/
