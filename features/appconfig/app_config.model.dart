import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:rxdart/rxdart.dart';

class AppConfigModel with ChangeNotifier {
  async.CancelableOperation<Result<AppRemoteConfig>>? _appConfigOp;
  Result<AppRemoteConfig>? appConfigResult;

  final _configResultStreamController =
      BehaviorSubject<Result<AppRemoteConfig>>();

  Stream<Result<AppRemoteConfig>> get configResultStream =>
      _configResultStreamController.stream;

  AppRemoteConfig? get appConfig =>
      _configResultStreamController.valueOrNull?.peek();

  AppConfigModel() {
    fetchAppConfig();
  }

  @override
  void dispose() {
    _appConfigOp?.cancel();
    super.dispose();
  }

  Future<void> fetchAppConfig() async {
    try {
      // Cancel current operation (if any)
      _appConfigOp?.cancel();

      if (appConfigResult != null) {
        appConfigResult = null;
        notifyListeners();
      }

      // Create Request
      _appConfigOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().miscRepository.fetchAppConfig());

      // Wait for result
      appConfigResult = await _appConfigOp?.value;
    } catch (error) {
      appConfigResult = Result.error("Error: $error");
    }

    _configResultStreamController.add(appConfigResult!);
    notifyListeners();
  }

  void skipUpdate() {
    final appConfig = this.appConfig;
    final updateInfo = appConfig?.updateInfo;
    if (updateInfo == null || updateInfo.required) {
      return;
    }

    _configResultStreamController.add(
      Result.success(appConfig!.skipUpdate()),
    );
  }
}
