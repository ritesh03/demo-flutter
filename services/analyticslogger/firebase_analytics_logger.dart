import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:kwotcommon/kwotcommon.dart';

class FirebaseAnalyticsLogger implements AnalyticsLogger {
  //=

  @override
  void initialize() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  @override
  Future<void> log(String message) async {
    FirebaseCrashlytics.instance.log(message);
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    FirebaseCrashlytics.instance.log(event.toString());
  }

  @override
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    dynamic reason,
  }) async {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: reason);
  }
}
