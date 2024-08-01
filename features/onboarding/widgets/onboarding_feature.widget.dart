import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class OnboardingFeature extends StatelessWidget {
  static final featureGraphicHeightFactor = 0.3185.sh;
  static final featureTitleHeightFactor = 80.h;
  static final featureSubtitleHeightFactor = 48.h;

  static double get totalHeightFactor {
    return featureGraphicHeightFactor +
        featureTitleHeightFactor +
        featureSubtitleHeightFactor +
        ComponentInset.normal.h;
  }

  const OnboardingFeature({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final graphicWidth = 1.sw;
    final graphicHeight = featureGraphicHeightFactor;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
            width: graphicWidth,
            height: graphicHeight,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              width: graphicWidth,
              height: graphicHeight,
            )),
        Container(
            height: featureTitleHeightFactor,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            child: Text(
              title,
              style: TextStyles.boldHeading1,
              textAlign: TextAlign.center,
            )),
        Container(
            height: featureSubtitleHeightFactor,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            child: Text(subtitle,
                style: TextStyles.body, textAlign: TextAlign.center)),
      ]),
    );
  }
}
