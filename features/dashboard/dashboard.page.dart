import 'package:flutter/material.dart'  hide SearchBar;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/features/dashboard/dashboard.model.dart';
import 'package:kwotmusic/features/profile/notifications/unread_notifications_count_monitor.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends PageState<DashboardPage> {
  DashboardModel get dashboardModel => context.read<DashboardModel>();

  @override
  void initState() {
    super.initState();

    // Ensure logged in
    // TODO: Observe session instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasSession = locator<SessionModel>().hasSession;
      if (!hasSession) {
        RootNavigation.popUntilRoot(context);
        DashboardNavigation.pushNamedAndRemoveUntil(
            context, Routes.authSignIn, (route) => false);
        return;
      }

      locator<UnreadNotificationsCountMonitor>().clearAndCheck();
      locator<SubscriptionDetailModel>().recheck();
      dashboardModel.resetSelectedTabIndex();

      InternetConnectionChecker().hasConnection.then((hasInternet) {
        if (!hasInternet) {
          RootNavigation.popUntilRoot(context);
          DashboardNavigation.pushNamed(context, Routes.downloads);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardModel = this.dashboardModel;
    return SafeArea(
        child: Scaffold(
            body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: dashboardModel.pageController,
                children: dashboardModel.getTabPages())));
  }
}
