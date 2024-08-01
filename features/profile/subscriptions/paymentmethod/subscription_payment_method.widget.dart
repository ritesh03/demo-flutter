import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class SubscriptionPaymentMethodWidget extends StatelessWidget {
  const SubscriptionPaymentMethodWidget({
    Key? key,
    required this.paymentMethod,
    required this.onTap,
  }) : super(key: key);

  final SubscriptionPaymentMethod paymentMethod;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(paymentMethod.name,
          style: TextStyles.boldHeading4
              .copyWith(color: DynamicTheme.get(context).white())),
      if (paymentMethod.description != null)
        Text(
          paymentMethod.description!,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral20()),
        ),
      SizedBox(height: ComponentInset.small.r),
      _SubscriptionPaymentMethodPhoto(
        photoUrl: paymentMethod.photo,
        onTap: onTap,
      ),
    ]);
  }
}

class _SubscriptionPaymentMethodPhoto extends StatelessWidget {
  const _SubscriptionPaymentMethodPhoto({
    Key? key,
    required this.photoUrl,
    required this.onTap,
  }) : super(key: key);

  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: ScaleTap(
        scaleMinValue: 0.98,
        onPressed: onTap,
        child: Photo(
          photoUrl,
          options: PhotoOptions(
              height: 150.r,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        ),
      ),
    );
  }
}
