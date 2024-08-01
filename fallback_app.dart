import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kwotcommon/kwotcommon.dart';

const _foregroundColor = Colors.white;
const _backgroundColor = Color(0xFF0F3443);

class KwotMusicFallbackApp extends StatefulWidget {
  const KwotMusicFallbackApp({Key? key}) : super(key: key);

  @override
  State<KwotMusicFallbackApp> createState() => _KwotMusicFallbackAppState();
}

class _KwotMusicFallbackAppState extends State<KwotMusicFallbackApp> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: _backgroundColor,
      systemNavigationBarColor: Colors.black,
    ));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _FallbackPage(),
      theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: "Poppins",
          scaffoldBackgroundColor: _backgroundColor,
          splashFactory: InkRipple.splashFactory,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      themeMode: ThemeMode.dark,
      title: LaunchConfig.app.title,
    );
  }
}

class _FallbackPage extends StatelessWidget {
  const _FallbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = "Something went wrong";
    final message = "Unfortunately, something went wrong when we were trying to"
        " launch the app. Please try relaunching the app. And, verify"
        " that you have the latest update from the app store. \n\n"
        "If nothing seems to work, you can try clearing app data and cache from"
        " your phone's settings. Reinstalling the app from app store may, also,"
        " help. \n\n"
        "You can always reach to us on ${LaunchConfig.app.supportEmail}";

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(title,
                  maxLines: 1,
                  style: TextStyle(
                      color: _foregroundColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(
                      color: _foregroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
