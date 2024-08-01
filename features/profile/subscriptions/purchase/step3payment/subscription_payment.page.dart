import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step4confirmation/subscription_payment_confirmation.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'subscription_payment.model.dart';

class SubscriptionPaymentPage extends StatefulWidget {
  const SubscriptionPaymentPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPaymentPage> createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState extends PageState<SubscriptionPaymentPage> {
  //=

  SubscriptionPaymentModel get _paymentModel =>
      context.read<SubscriptionPaymentModel>();

  late SubscriptionPaymentState _paymentState;
  late StreamSubscription _paymentStateStreamSubscription;

  @override
  void initState() {
    super.initState();
    _paymentState = SubscriptionPaymentState.initializing;

    _paymentStateStreamSubscription =
        _paymentModel.paymentStateStream.distinct().listen((state) {
      if (state != _paymentState) {
        setState(() => (_paymentState = state));
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initializePaymentRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.sync(() => false),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(ComponentInset.normal.r),
            child: AspectRatio(
                aspectRatio: 1,
                child: Column(children: [
                  _PaymentStatusText(state: _paymentState),
                  const Expanded(child: LoadingIndicator()),
                ])),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paymentStateStreamSubscription.cancel();
    super.dispose();
  }

  void _initializePaymentRequest() async {
    final result = await context
        .read<SubscriptionPaymentModel>()
        .initializePaymentRequest(context);

    final args = SubscriptionPaymentConfirmationArgs(
      selectedPlan: _paymentModel.selectedPlan,
      subscriptionOrderResult: result,
    );

    if (!mounted) return;

    DashboardNavigation.pushReplacementNamed(
      context,
      Routes.subscriptionPlanPaymentConfirmation,
      arguments: args,
    );
  }
}

class _PaymentStatusText extends StatelessWidget {
  const _PaymentStatusText({
    Key? key,
    required this.state,
  }) : super(key: key);

  final SubscriptionPaymentState state;

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);
    final text = _getDisplayStatusForPaymentState(
      localeResource: localeResource,
      state: state,
    );

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyles.boldHeading3
          .copyWith(color: DynamicTheme.get(context).white()),
    );
  }

  String _getDisplayStatusForPaymentState({
    required TextLocaleResource localeResource,
    required SubscriptionPaymentState state,
  }) {
    switch (state) {
      case SubscriptionPaymentState.initializing:
        return localeResource.subscriptionPaymentStateInitializing;
      case SubscriptionPaymentState.processing:
        return localeResource.subscriptionPaymentStateProcessing;
      case SubscriptionPaymentState.completed:
        return localeResource.subscriptionPaymentStateCompleted;
      case SubscriptionPaymentState.failed:
        return localeResource.subscriptionPaymentStateFailed;
    }
  }
}
