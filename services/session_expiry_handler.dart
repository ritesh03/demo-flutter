import 'package:kwotdata/api/session_expiry_handler.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/router/routes.dart';

class UserSessionExpiryHandler extends SessionExpiryHandler {
  //=

  @override
  void onSessionExpired() {
    final navigationContext = DashboardNavigation.navigatorKey.currentContext;
    if (navigationContext != null) {
      RootNavigation.popUntilRoot(navigationContext);
      DashboardNavigation.pushNamedAndRemoveUntil(
        navigationContext,
        Routes.authSignIn,
        (route) => false,
      );
    }
  }
}
