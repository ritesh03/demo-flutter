import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/features/dashboard/dashboard.model.dart';
import 'package:provider/provider.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(376, 664),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: () => child);
  }
}

class AppBuilder extends StatelessWidget {
  const AppBuilder({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.setContext(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: DynamicTheme.get(context).background(),
      systemNavigationBarColor: Colors.black,
    ));

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => AppConfigModel()),
          ChangeNotifierProvider(create: (_) => DashboardModel()),
        ], child: child));
  }
}
