import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/appconfig/app_config.model.dart';
import 'package:kwotmusic/features/appconfig/fragment/app_config_fragment.dart';
import 'package:provider/provider.dart';

class AppConfigPage extends StatelessWidget {
  const AppConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            backgroundColor: DynamicTheme.get(context).black(),
            body: SizedBox.expand(
              child: Stack(children: const [
                _PageBackground(),
                Positioned(
                    bottom: 0, left: 0, right: 0, child: _PageForeground()),
              ]),
            )));
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Photo(Assets.iconLauncher,
        options: PhotoOptions(
          width: 84.r,
          height: 84.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
        ));
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ForegroundGradientPhoto(
        photoPath: Assets.backgroundLiveShow,
        height: 0.55.sh,
        startColor: DynamicTheme.get(context).black(),
        startColorShift: 0.1,
        photoAlignment: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter);
  }
}

class _PageForeground extends StatelessWidget {
  const _PageForeground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 0.75.sh,
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: Column(children: [
          /// ICON
          const _AppIcon(),
          SizedBox(height: ComponentInset.medium.r),

          /// Fragments
          Expanded(
            child: Selector<AppConfigModel, Result<AppRemoteConfig>?>(
                selector: (_, model) => model.appConfigResult,
                builder: (_, result, __) =>
                    AppConfigFragment(configResult: result)),
          ),
        ]));
  }
}
