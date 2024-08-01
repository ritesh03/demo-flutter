import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomnavbar/bottom_nav_bar.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/features/appconfig/app_config.page.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/router/router.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard.model.dart';
import 'dashboard/dashboard_config.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends PageState<IndexPage> {
  AppConfigModel get _appConfigModel => context.read<AppConfigModel>();

  DashboardModel get dashboardModel => context.read<DashboardModel>();

  @override
  void initState() {
    super.initState();

    _appConfigModel.configResultStream.listen((result) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Result<AppRemoteConfig>>(
        stream: _appConfigModel.configResultStream,
        builder: (_, snapshot) {
          final result = snapshot.data;
          final config = result?.peek();
          if (config == null || config.hasBlockers) {
            return const AppConfigPage();
          }

          return SafeArea(
            top: false,
            child: Scaffold(
              body: Stack(children: [
                Positioned.fill(child: _buildContent()),
                Positioned(
                    left: 0, right: 0, bottom: 0, child: _buildPlaybackBar()),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildNavigationTabBar()),
              ]),
            ),
          );
        });
  }

  Widget _buildContent() {
    return WillPopScope(
        onWillPop: () async {
          final handled = await DashboardNavigation.maybePop();
          if (handled) {
            return false;
          }

          return true;
        },
        child: Navigator(
          key: DashboardNavigation.navigatorKey,
          onGenerateInitialRoutes: (state, routeName) {
            return RouteManager.generateInitialRoutes(routeName);
          },
          onGenerateRoute: RouteManager.generateRoute,
          initialRoute: locator<SessionModel>().hasSession
              ? Routes.dashboard
              : Routes.onboarding,
          observers: [NavigationHistoryObserver()],
        ));
  }

  Widget _buildPlaybackBar() {
    return ValueListenableBuilder<DashboardConfig>(
        valueListenable: dashboardModel.dashboardConfigNotifier,
        builder: (_, config, __) {
          double totalHeight = config.playbackBarHeight;
          if (config.isPlaybackBarVisible && config.isNavigationBarVisible) {
            totalHeight += config.navigationBarHeight;
          }

          return AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                height: totalHeight,
                child: const CompactPlaybackBar(),
              ));
        });
  }

  Widget _buildNavigationTabBar() {
    return ValueListenableBuilder<DashboardConfig>(
        valueListenable: dashboardModel.dashboardConfigNotifier,
        builder: (_, config, __) {
          return BottomNavBar(
              backgroundColor: DynamicTheme.get(context).black(),
              circleGradient: DynamicTheme.get(context).primaryGradient(),
              circleSize: 56.r,
              height: 64.r,
              iconColor: DynamicTheme.get(context).neutral20(),
              iconSize: 32.r,
              items: dashboardModel.getNavigationBarItems(context),
              onTap: (index) {
                dashboardModel
                  ..setSelectedTabIndex(index)
                  ..pageController.jumpToPage(index);
              },
              selectedIconColor: DynamicTheme.get(context).white(),
              selectedIconSize: 40.r,
              selectedIndex: config.selectedTabIndex,
              visible: config.isNavigationBarVisible);
        });
  }
}
