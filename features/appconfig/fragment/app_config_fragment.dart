import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/features/appconfig/fragment/app_update_fragment.dart';
import 'package:kwotmusic/features/appconfig/fragment/loading_config_fragment.dart';
import 'package:provider/provider.dart';

import 'app_maintenance_fragment.dart';

class AppConfigFragment extends StatelessWidget {
  const AppConfigFragment({
    Key? key,
    required this.configResult,
  }) : super(key: key);

  final Result<AppRemoteConfig>? configResult;

  @override
  Widget build(BuildContext context) {
    final result = configResult;
    if (result == null) return const LoadingConfigFragment();
    if (!result.isSuccess()) {
      return Center(
          child: ErrorIndicator(
              error: result.error(),
              onTryAgain: () {
                context.read<AppConfigModel>().fetchAppConfig();
              }));
    }

    final config = result.data();

    final maintenanceInfo = config.maintenanceInfo;
    if (maintenanceInfo != null) {
      return AppMaintenanceFragment(maintenanceInfo: maintenanceInfo);
    }

    final updateInfo = config.updateInfo;
    if (updateInfo != null) {
      return AppUpdateFragment(updateInfo: updateInfo);
    }

    throw Exception("App-config doesn't have any blockers: $config");
  }
}
