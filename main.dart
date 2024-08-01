import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart' show GetMaterialApp;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/app_wrapper.dart';
import 'package:kwotmusic/features/index.page.dart';
import 'package:kwotmusic/util/get_context.dart';
import 'package:kwotmusic/util/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/kit/kit.dart';
import 'fallback_app.dart';
import 'kwotapp.dart';
import 'l10n/localizations.dart';

void main() async {

  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);


    await KwotApp().init();

    runApp(const KwotMusicApp());
  } catch (error) {
    debugPrint("||- Error: $error");
    runApp(const KwotMusicFallbackApp());
  }
  SharedPref.prefs = await SharedPreferences.getInstance();
}

class KwotMusicApp extends StatelessWidget {
  const KwotMusicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWrapper(
      /// [GetMaterialApp] is required by "overlayContext" in [NotificationBar]
      child: GetMaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        builder: (context, child) => AppBuilder(child: child!),
        debugShowCheckedModeBanner: false,
        home: const IndexPage(),
        // initialRoute: (Session.isValid) ? Routes.dashboard : Routes.onboarding,
        // onGenerateInitialRoutes: RouteManager.generateInitialRoutes,
        // onGenerateRoute: RouteManager.generateRoute,
        localizationsDelegates: const [
          LocaleResources.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code (US)
        ],
        theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: "Poppins",
            scaffoldBackgroundColor: DynamicTheme.get(context).background(),
            splashFactory: InkRipple.splashFactory,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        themeMode: ThemeMode.dark,
        title: LaunchConfig.app.title,
      ),
    );
  }
}
