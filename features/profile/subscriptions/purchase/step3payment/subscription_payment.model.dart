import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_detail.model.dart';
import 'package:flutterwave_standard/flutterwave.dart' as flw;
import 'package:rxdart/rxdart.dart';

class SubscriptionPaymentArgs {
  SubscriptionPaymentArgs({
    required this.billingDetail,
    required this.paymentMethod,
    required this.plan,
    required this.order,
  });

  final BillingDetail billingDetail;
  final SubscriptionPaymentMethod paymentMethod;
  final SubscriptionPlan plan;
  final TemporarySubscriptionOrder order;
}

enum SubscriptionPaymentState { initializing, processing, completed, failed }

class SubscriptionPaymentModel with ChangeNotifier {
  final SubscriptionPaymentArgs _args;

  final _paymentStateSubject = BehaviorSubject<SubscriptionPaymentState>();

  SubscriptionPaymentModel({
    required SubscriptionPaymentArgs args,
  }) : _args = args {
    _paymentStateSubject.add(SubscriptionPaymentState.initializing);
  }

  SubscriptionPlan get selectedPlan => _args.plan;

  ValueStream<SubscriptionPaymentState> get paymentStateStream =>
      _paymentStateSubject.stream;

  SubscriptionPaymentState get paymentState => paymentStateStream.value;

  Future<Result<SubscriptionOrder>> initializePaymentRequest(
    BuildContext context,
  ) async {
    // Step 1: Process Payment
    final paymentGateway = _FlutterwavePaymentGateway(
      billingDetail: _args.billingDetail,
      plan: _args.plan,
    );
    final chargeResult = await paymentGateway.chargePayment(
      context,
      transactionReference: _args.order.paymentToken,
    );
    _paymentStateSubject.add(SubscriptionPaymentState.processing);

    if (!chargeResult.isSuccess()) {
      _paymentStateSubject.add(SubscriptionPaymentState.failed);
      return Result.error(chargeResult.error());
    }

    // Step 2: Verify Payment Status
    final confirmationRequest =
        ConfirmSubscriptionOrderRequest(orderId: _args.order.orderId);

    final confirmationResult = await locator<KwotData>()
        .subscriptionRepository
        .confirmSubscriptionOrder(confirmationRequest);

    if (!confirmationResult.isSuccess()) {
      _paymentStateSubject.add(SubscriptionPaymentState.failed);
      return Result.error(confirmationResult.error());
    }

    // Step 3: Retrieve Subscription Order
    final subscriptionOrderRequest = SubscriptionOrderRequest(
      orderId: _args.order.orderId,
    );
    final subscriptionOrderResult = await locator<KwotData>()
        .subscriptionRepository
        .fetchSubscriptionOrder(subscriptionOrderRequest);
    if (!subscriptionOrderResult.isSuccess() ||
        subscriptionOrderResult.isEmpty()) {
      _paymentStateSubject.add(SubscriptionPaymentState.failed);
      return Result.error(subscriptionOrderResult.error());
    }

    // Step 4: Refresh active subscription-detail
    locator<SubscriptionDetailModel>().refreshSubscriptionDetail();

    // Step 5: Return completed subscription-order
    _paymentStateSubject.add(SubscriptionPaymentState.completed);
    return subscriptionOrderResult;
  }
}

class _FlutterwavePaymentGateway {
  final SubscriptionPlan plan;
  final BillingDetail billingDetail;

  _FlutterwavePaymentGateway({
    required this.plan,
    required this.billingDetail,
  });

  Future<Result> chargePayment(
    BuildContext context, {
    required String transactionReference,
  }) async {
    final customer = flw.Customer(
      name: billingDetail.name,
      email: "customer@customer.com",
      phoneNumber: null,
    );

    final flutterwave = flw.Flutterwave(
      context: context,
      currency: plan.payment!.currency.isoCode,
      publicKey: "FLWPUBK_TEST-ce2d6030fd47fccfcfe01ec5df82f357-X",
      txRef: transactionReference,
      amount: plan.payment!.price,
      customer: customer,
      paymentOptions: "card",
      customization: flw.Customization(
        title: "Test Payment",
      ),
      redirectUrl: "https://music.kwot.com",
      isTestMode: true,
    );

    final response = await flutterwave.charge();
    if (response.success) {
      return Result.empty();
    } else {
      return Result.error("Payment failed.");
    }
  }
}
