import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:great_list_view/great_list_view.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';

import 'app_config.dart';
import 'components/widgets/feed/feed_routing.dart';
import 'features/album/album_actions.model.dart';
import 'features/artist/artist_actions.model.dart';
import 'features/auth/auth_actions.model.dart';
import 'features/auth/session/session.model.dart';
import 'features/downloads/downloads_actions.model.dart';
import 'features/playback/audio/audio_playback_actions.model.dart';
import 'features/playback/audio/playback_item_actions.model.dart';
import 'features/playback/video/video_playback.manager.dart';
import 'features/playlist/playlist_actions.model.dart';
import 'features/podcastepisode/podcast_episode_actions.model.dart';
import 'features/profile/notifications/unread_notifications_count_monitor.dart';
import 'features/profile/subscriptions/subscription_detail.model.dart';
import 'features/radiostation/radio_station_actions.model.dart';
import 'features/search/search_actions.model.dart';
import 'features/show/show_actions.model.dart';
import 'features/skit/skit_actions.model.dart';
import 'features/track/track_actions.model.dart';
import 'features/user/user_actions.model.dart';
import 'firebase_options.dart';
import 'services/analyticslogger/firebase_analytics_logger.dart';
import 'services/session_expiry_handler.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


class KwotApp {
  //=

  Future<void> init() async {
    /// Set device orientation
    await SystemChrome.setPreferredOrientations(
        AppConfig.allowedDeviceOrientations);

    /// initialize firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// Isolate instantiation can block main thread. Hence, frame drops are
    /// possible. So, it is better to warm yp the executor beforehand.
    /// From https://pub.dev/packages/worker_manager
    /// For https://pub.dev/packages/great_list_view
    await Executor().warmUp();


    /// https://pub.dev/packages/get_storage
    await GetStorage.init();

    /// Setup + Register Locator
    await _setupServiceLocator();

    /// Load session information
    _initSession();


    /// Initialize Analytics
    locator<AnalyticsLogger>().initialize();

    /// Initialize Downloads: remove lazy-ness
    locator<DownloadActionsModel>();

    /// Initialize Subscription Detail: remove lazy-ness
    locator<SubscriptionDetailModel>();
  }

  Future<void> _setupServiceLocator() async {
    /// Commons
    KwotCommon.init(
      analyticsLogger: LaunchConfig.build.inDevelopment
          ? DebugAnalyticsLogger()
          : FirebaseAnalyticsLogger(),
    );

    /// Data
    final kwotData = KwotData();
    await kwotData.initialize(
      baseUrl: LaunchConfig.api.url,
      sessionExpiryHandler: UserSessionExpiryHandler(),
      mock: LaunchConfig.build.useMockImplementations,
      debug: LaunchConfig.build.inDevelopment,
    );
    locator.registerSingleton<KwotData>(kwotData);

    /// Album Actions
    locator.registerLazySingleton<AlbumActionsModel>(() {
      return AlbumActionsModel();
    });

    /// Artist Actions
    locator.registerLazySingleton<ArtistActionsModel>(() {
      return ArtistActionsModel();
    });

    /// Audio Playback Actions
    locator.registerLazySingleton<AudioPlaybackActionsModel>(() {
      return AudioPlaybackActionsModel();
    });

    /// Auth Actions
    locator.registerLazySingleton<AuthActionsModel>(() {
      return AuthActionsModel();
    });

    /// Downloads
    locator.registerLazySingleton<DownloadActionsModel>(() {
      return DownloadActionsModel();
    });

    /// Feed Routing
    locator.registerLazySingleton<FeedRouting>(() {
      return FeedRouting();
    });

    /// Playback Item Actions
    locator.registerLazySingleton<PlaybackItemActionsModel>(() {
      return PlaybackItemActionsModel();
    });

    /// Playlist Actions
    locator.registerLazySingleton<PlaylistActionsModel>(() {
      return PlaylistActionsModel();
    });

    /// Podcast Episode Actions
    locator.registerLazySingleton<PodcastEpisodeActionsModel>(() {
      return PodcastEpisodeActionsModel();
    });

    /// Radio Station Actions
    locator.registerLazySingleton<RadioStationActionsModel>(() {
      return RadioStationActionsModel();
    });

    /// Search Actions
    locator.registerLazySingleton<SearchActionsModel>(() {
      return SearchActionsModel();
    });

    /// Session
    locator.registerLazySingleton<SessionModel>(() {
      return SessionModel();
    });

    /// Show Actions
    locator.registerLazySingleton<ShowActionsModel>(() {
      return ShowActionsModel();
    });

    /// Skit Actions
    locator.registerLazySingleton<SkitActionsModel>(() {
      return SkitActionsModel();
    });

    /// Subscription Detail
    locator.registerLazySingleton<SubscriptionDetailModel>(() {
      return SubscriptionDetailModel();
    });

    /// Track Actions
    locator.registerLazySingleton<TrackActionsModel>(() {
      return TrackActionsModel();
    });

    /// Unread notifications count monitor
    locator.registerSingleton<UnreadNotificationsCountMonitor>(
      UnreadNotificationsCountMonitor(),
    );

    /// User Actions
    locator.registerLazySingleton<UserActionsModel>(() {
      return UserActionsModel();
    });

    /// Video Playback Manager
    locator.registerLazySingleton<VideoPlaybackManager>(() {
      return VideoPlaybackManager();
    });
  }

  Future<void> _initSession() async {
    final data = locator.get<KwotData>();
    final storageRepository = data.storageRepository;
    data.updateSessionUser(
      userId: storageRepository.getUserId(),
      userToken: storageRepository.getToken(),
      userRefreshToken: storageRepository.getRefreshToken(),
      save: false,
    );
  }
}
