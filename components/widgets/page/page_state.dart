import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';

// Analytics Note:
// I think it is better if I observe a state-variable from the page
// and list the changes (instead). But, this requires too much
// ground work as of now.
abstract class PageState<T extends StatefulWidget> extends State<T> {
  String? pageTag;

  String? _routeName;
  late PageAnalytics analytics;

  @override
  void initState() {
    super.initState();

    analytics = PageAnalytics(
      tag: pageTag ?? "unknown",
      logger: locator<AnalyticsLogger>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final routeSettings = ModalRoute.of(context)?.settings;
      _routeName = routeSettings?.name;
      analytics
          .log("Route $_routeName visited {arg:'${routeSettings?.arguments}'}");
    });
  }

  @override
  void dispose() {
    analytics.log("Route $_routeName left");
    super.dispose();
  }
}
