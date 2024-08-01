import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';

class SubscriptionRequirementIndicator extends StatelessWidget {
  const SubscriptionRequirementIndicator({
    Key? key,
    required this.feature,
    required this.size,
  }) : super(key: key);

  final SubscriptionFeature feature;
  final double size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SubscriptionFeature>?>(
        stream: locator<SubscriptionDetailModel>().availableFeaturesStream,
        builder: (_, snapshot) {
          final features = snapshot.data;
          if (features != null && features.contains(feature)) {
            return const SizedBox.shrink();
          }

          return AspectRatio(
            aspectRatio: 1,
            child: Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                Assets.iconCrown,
                width: size,
                height: size,
                color: DynamicTheme.get(context).primary60(),
              ),
            ),
          );
        });
  }
}
