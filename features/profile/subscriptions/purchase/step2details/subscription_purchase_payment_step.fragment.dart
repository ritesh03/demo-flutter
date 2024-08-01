import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/features/profile/subscriptions/paymentmethod/subscription_payment_method.widget.dart';
import 'package:kwotmusic/features/profile/subscriptions/paymentmethod/subscription_payment_methods.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

/// Requires [SubscriptionPaymentMethodsModel]
class SubscriptionPurchasePaymentStepFragment extends StatefulWidget {
  const SubscriptionPurchasePaymentStepFragment({
    Key? key,
    required this.onPaymentMethodTap,
  }) : super(key: key);

  final Function(SubscriptionPaymentMethod) onPaymentMethodTap;

  @override
  State<SubscriptionPurchasePaymentStepFragment> createState() =>
      _SubscriptionPurchasePaymentStepFragmentState();
}

class _SubscriptionPurchasePaymentStepFragmentState
    extends State<SubscriptionPurchasePaymentStepFragment> {
  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Text(localeResource.choosePaymentMethod,
            style: TextStyles.boldHeading2
                .copyWith(color: DynamicTheme.get(context).white())),
      ),
      SizedBox(height: ComponentInset.normal.r),
      Expanded(
        child: _PaymentMethodsWidget(
          localeResource: localeResource,
          onTap: widget.onPaymentMethodTap,
        ),
      ),
    ]);
  }
}

class _PaymentMethodsWidget extends StatelessWidget {
  const _PaymentMethodsWidget({
    Key? key,
    required this.localeResource,
    required this.onTap,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final Function(SubscriptionPaymentMethod) onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<SubscriptionPaymentMethodsModel,
            SubscriptionPaymentMethodsResult?>(
        selector: (_, model) => model.paymentMethodsResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
              error: result.error(),
              onTryAgain: () => _refresh(context),
            );
          }

          if (result.isEmpty()) {
            return _EmptyPaymentMethodsWidget(localeResource: localeResource);
          }

          final paymentMethods = result.data();
          return ListView.separated(
            padding: EdgeInsets.all(ComponentInset.normal.r),
            itemCount: paymentMethods.length,
            separatorBuilder: (_, __) {
              return SizedBox(height: ComponentInset.large.r);
            },
            itemBuilder: (_, index) {
              final paymentMethod = paymentMethods[index];
              return SubscriptionPaymentMethodWidget(
                paymentMethod: paymentMethod,
                onTap: () => onTap(paymentMethod),
              );
            },
          );
        });
  }

  void _refresh(BuildContext context) {
    context.read<SubscriptionPaymentMethodsModel>().fetchPaymentMethods();
  }
}

class _EmptyPaymentMethodsWidget extends StatelessWidget {
  const _EmptyPaymentMethodsWidget({
    Key? key,
    required this.localeResource,
  }) : super(key: key);

  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: ComponentInset.larger.r),
      Text(localeResource.emptySubscriptionPaymentMethods,
          textAlign: TextAlign.center,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral10())),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}
