import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A placeholder class to access hidden "flutter_gen/gen_l10n" files,
/// helps lint find localized resources
class LocaleResources {
  static const LocalizationsDelegate delegate = AppLocalizations.delegate;

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}

typedef TextLocaleResource = AppLocalizations;
