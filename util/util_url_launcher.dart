import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class UrlLauncherUtil {
  //=

  static Future<bool> openPrivacyPolicyPage(BuildContext context) async {
    final url = context.read<AppConfigModel?>()?.appConfig?.privacyPolicyUrl ??
        LaunchConfig.app.privacyUrl;
    return _openWebPage(context: context, url: url);
  }

  static Future<bool> openTermsConditionsPage(BuildContext context) async {
    final url = context.read<AppConfigModel?>()?.appConfig?.termsUrl ??
        LaunchConfig.app.termsUrl;
    return _openWebPage(context: context, url: url);
  }

  static Future<bool> openMerchandisingPage(BuildContext context) async {
    final url = LaunchConfig.app.merchandisingUrl;
    return _openWebPage(context: context, url: url);
  }
  static Future<bool> buyToken(BuildContext context) async {
    final url = LaunchConfig.app.buyTokenUrl;
    print("This is the url for buy token $url");
    return _openWebPage(context: context, url: url);
  }

  static Future<bool> openPageForProduct(BuildContext context,url) async {
    return _openWebPage(context: context, url: url);
  }

  static Future<bool> _openWebPage({
    required BuildContext context,
    required String url,
  }) async {
    switch (LaunchConfig.operatingSystem) {
      case OperatingSystem.android:
        return _openWebPageInInternalBrowser(context: context, url: url);
      case OperatingSystem.ios:
        // App Tracking Transparency Prevention
        return _openWebPageInExternalBrowser(url: url);
      case OperatingSystem.unknown:
        return _openWebPageInExternalBrowser(url: url);
    }
  }

  static Future<bool> _openWebPageInInternalBrowser({
    required BuildContext context,
    required String url,
  }) async {
    try {
      await custom_tabs.launch(url,
          customTabsOption: custom_tabs.CustomTabsOption(
              toolbarColor: DynamicTheme.get(context).black(),
              enableDefaultShare: false,
              enableUrlBarHiding: false,
              showPageTitle: false,
              extraCustomTabs: const <String>[
                // https://play.google.com/store/apps/details?id=org.mozilla.firefox
                'org.mozilla.firefox',
                // https://play.google.com/store/apps/details?id=com.microsoft.emmx
                'com.microsoft.emmx',
              ]),
          safariVCOption: custom_tabs.SafariViewControllerOption(
            preferredBarTintColor: DynamicTheme.get(context).black(),
            preferredControlTintColor: Colors.white,
            barCollapsingEnabled: true,
            entersReaderIfAvailable: false,
            dismissButtonStyle:
                custom_tabs.SafariViewControllerDismissButtonStyle.close,
          ));
      return true;
    } catch (error, stack) {
      await locator<AnalyticsLogger>().logError(error, stack,
          reason: "Couldn't open custom-tabs web page: $url");
      return _openWebPageInExternalBrowser(url: url);
    }
  }

  static Future<bool> _openWebPageInExternalBrowser({
    required String url,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      return await url_launcher.launchUrl(uri);
    } catch (error, stack) {
      await locator<AnalyticsLogger>().logError(error, stack,
          reason: "Couldn't open web page with url-launcher: $url");
      return false;
    }
  }
}
