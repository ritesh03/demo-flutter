import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomnavbar/bottom_nav_bar.widget.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';

import 'account/account_home.model.dart';
import 'account/account_home.page.dart';
import 'comedy/comedy_home.model.dart';
import 'comedy/comedy_home.page.dart';
import 'dashboard_config.dart';
import 'library/library_home.model.dart';
import 'library/library_home.page.dart';
import 'music/music_home.model.dart';
import 'music/music_home.page.dart';
import 'podcasts/podcasts_home.model.dart';
import 'podcasts/podcasts_home.page.dart';

class DashboardModel with ChangeNotifier {
  final navigationBarItems = <BottomNavBarItem>[];

  final dashboardConfigNotifier =
      ValueNotifier<DashboardConfig>(DashboardConfig());

  late PageController _pageController;

  StreamSubscription<LogoutEvent>? _logoutEventSubscription;

  DashboardModel() {
    final dashboardConfig = dashboardConfigNotifier.value;
    _pageController =
        PageController(initialPage: dashboardConfig.selectedTabIndex);

    _listenToNavigationHistory();
    _listenToAudioPlaybackActivity();
    _listenToVideoPlaybackActivity();
    _logoutEventSubscription = _listenToLogout();
  }

  @override
  void dispose() {
    _logoutEventSubscription?.cancel();
    _navigationHistoryStreamSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// PAGE CONTROLLER

  PageController get pageController => _pageController;

  /// TAB: SELECTED INDEX
  /// comedians, radio, [music, library], account

  void setSelectedTabIndex(int index) {
    dashboardConfigNotifier.value =
        dashboardConfigNotifier.value.copyWith(selectedTabIndex: index);
  }

  void resetSelectedTabIndex() {
    final defaultTabIndex = DashboardConfig().selectedTabIndex;
    setSelectedTabIndex(defaultTabIndex);
  }

  /// TABS & TAB PAGES

  List<Widget> getTabPages() {
    return [
      /// COMEDY
      ChangeNotifierProvider(
        create: (_) => ComedyHomeModel(),
        builder: (_, __) => const ComedyHomePage(),
      ),

      /// PODCASTS
      ChangeNotifierProvider(
        create: (_) => PodcastsHomeModel(),
        builder: (_, __) => const PodcastsHomePage(),
      ),

      /// MUSIC
      ChangeNotifierProvider(
        create: (_) => MusicHomeModel(),
        builder: (_, __) => const MusicHomePage(),
      ),

      // /// LIBRARY
      ChangeNotifierProvider(
        create: (_) => LibraryHomeModel(),
        builder: (_, __) => const LibraryHomePage(),
      ),

      /// ACCOUNT
      ChangeNotifierProvider(
        create: (_) => AccountHomeModel(),
        builder: (_, __) => const AccountHomePage(),
      ),
    ];
  }

  /// NAVIGATION BAR: ITEMS & VISIBILITY

  final _navigationHistoryObserver = NavigationHistoryObserver();
  StreamSubscription? _navigationHistoryStreamSubscription;

  List<BottomNavBarItem> getNavigationBarItems(BuildContext context) {
    if (navigationBarItems.isNotEmpty) {
      return navigationBarItems;
    }

    _loadNavigationBarItems(context);
    return navigationBarItems;
  }

  void _loadNavigationBarItems(BuildContext context) {
    final localization = LocaleResources.of(context);
    navigationBarItems.clear();

    /// COMEDY
    navigationBarItems.add(BottomNavBarItem(
      text: localization.video,
      iconPath: Assets.videoIconNew,
    ));

    /// PODCASTS
    navigationBarItems.add(BottomNavBarItem(
      text: localization.tabPodcasts,
      iconPath: Assets.iconPodcasts,
    ));

    /// MUSIC
    navigationBarItems.add(BottomNavBarItem(
      text: localization.tabMusic,
      iconPath: Assets.iconMusicNote,
    ));

    // /// LIBRARY
    navigationBarItems.add(BottomNavBarItem(
      text: localization.tabLibrary,
      iconPath: Assets.iconLibrary,
    ));

    /// PROFILE
    navigationBarItems.add(BottomNavBarItem(
      text: localization.tabProfile,
      iconPath: Assets.iconProfile,
      isProfileTabItem: true,
    ));
  }

  void _listenToNavigationHistory() {
    _navigationHistoryStreamSubscription =
        _navigationHistoryObserver.historyChangeStream.listen((event) {
      final topRoute = _navigationHistoryObserver.top;
      final topRouteName = topRoute?.settings.name;

      final dashboardConfig = dashboardConfigNotifier.value;
      dashboardConfigNotifier.value = dashboardConfig.copyWith(
        isNavigationBarVisible: (Routes.dashboard == topRouteName),
      );
    });
  }

  /// PLAYBACK BAR: VISIBILITY

  void _listenToAudioPlaybackActivity() {
    audioPlayerManager.playbackItemStream.listen((playbackItem) {
      final canPlay = playbackItem != null;

      final dashboardConfig = dashboardConfigNotifier.value;
      dashboardConfigNotifier.value = dashboardConfig.copyWith(
          isAudioPlaybackBarVisible: canPlay,
          isVideoPlaybackBarVisible:
              canPlay ? false : dashboardConfig.isVideoPlaybackBarVisible);
    });
  }

  void _listenToVideoPlaybackActivity() {
    videoPlayerManager.videoItemNotifier.addListener(() {
      final videoItem = videoPlayerManager.videoItemNotifier.value;
      final canPlay = videoItem != null;

      final dashboardConfig = dashboardConfigNotifier.value;
      dashboardConfigNotifier.value = dashboardConfig.copyWith(
          isVideoPlaybackBarVisible: canPlay,
          isAudioPlaybackBarVisible:
              canPlay ? false : dashboardConfig.isAudioPlaybackBarVisible);
    });
  }

  StreamSubscription<LogoutEvent> _listenToLogout() {
    return eventBus.on<LogoutEvent>().listen((event) {
      /// Reset selected tab position
      resetSelectedTabIndex();
    });
  }

  /// UTILS

  void hideNavigationAndPlaybackBar() {
    final dashboardConfig = dashboardConfigNotifier.value;
    dashboardConfigNotifier.value = dashboardConfig.copyWith(
      isNavigationBarVisible: false,
      isVideoPlaybackBarVisible: false,
      isAudioPlaybackBarVisible: false,
    );
  }
}
