import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:rxdart/rxdart.dart';

typedef SubscriptionDetailResult = Result<SubscriptionDetail>;
typedef SubscriptionPlansResult = Result<List<SubscriptionPlan>>;

class SubscriptionDetailModel {
  final _subscriptionDetailUseCase = _SubscriptionDetailUseCase();
  final _subscriptionPlansUseCase = _SubscriptionPlansUseCase();

  SubscriptionDetailModel() {
    _subscriptionDetailUseCase.fetchSubscriptionDetail();
    _subscriptionPlansUseCase.fetchSubscriptionPlans(forceRefresh: true);
  }

  ValueStream<SubscriptionDetailResult?> get subscriptionDetailStream =>
      _subscriptionDetailUseCase.stream;

  Stream<List<SubscriptionFeature>?> get availableFeaturesStream =>
      subscriptionDetailStream.map((result) => result?.peek()?.plan!.features)
          .distinct();

  ValueStream<SubscriptionPlansResult?> get subscriptionPlansStream =>
      _subscriptionPlansUseCase.stream;

  SubscriptionPlan? getSubscriptionPlanByFeature(SubscriptionFeature feature) {
    final result = subscriptionPlansStream.valueOrNull;

    final subscriptionPlans = result?.peek();
    if (subscriptionPlans == null || subscriptionPlans.isEmpty) return null;

    return subscriptionPlans
        .firstWhereOrNull((plan) => plan.features?.contains(feature)??false);
  }

  SubscriptionPlan? getSubscriptionPlanByIndex(int index) {
    return subscriptionPlansStream.valueOrNull?.peek()?[index];
  }

  bool isFeatureAwarded(String feature) {
    final result = subscriptionDetailStream.valueOrNull;


    final subscriptionDetail = result?.peek();

    if (subscriptionDetail == null) return false;
    if (subscriptionDetail.plan!.features?.isEmpty??false) return false;
    for (int i=0; i<(subscriptionDetail.plan!.features?.length??0);i++){
      if(subscriptionDetail.plan!.features![i].slug == feature) return true;
    }

     return false;

  }

  void recheck() {
    refreshSubscriptionDetail();
  }

  void refreshSubscriptionDetail() {
    _subscriptionDetailUseCase.fetchSubscriptionDetail();
  }

  void refreshSubscriptionPlans() {
    _subscriptionPlansUseCase.fetchSubscriptionPlans(forceRefresh: true);
  }

  void dispose() {
    _subscriptionDetailUseCase.dispose();
  }
}

class _SubscriptionDetailUseCase {
  late final Timer _timer;
  final _resultSubject = BehaviorSubject<SubscriptionDetailResult?>();

  _SubscriptionDetailUseCase() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkSubscriptionDetail();
    });
  }

  ValueStream<SubscriptionDetailResult?> get stream => _resultSubject.stream;

  SubscriptionDetailResult? get _result => stream.valueOrNull;

  void fetchSubscriptionDetail() async {
    if (!locator<SessionModel>().hasSession) {
      _resultSubject.add(Result.empty());
      return;
    }

    try {
      if (_result != null) {
        _resultSubject.add(null);
      }

      final result = await locator<KwotData>().subscriptionRepository.fetchSubscriptionDetail();

      _resultSubject.add(result);
    } catch (error) {
      final result = Result<Never>.error("Error: $error");
      _resultSubject.add(result);
    }
  }

  void _checkSubscriptionDetail() {
    final subscriptionDetail = _result?.peek();
    if (subscriptionDetail != null) {
      final activation = subscriptionDetail.activation;
      if (activation == null) return;
    }

    if (!locator<SessionModel>().hasSession) {
      _resultSubject.add(Result.empty());
      return;
    }

    locator<KwotData>()
        .subscriptionRepository
        .fetchSubscriptionDetail()
        .then((result) {
      if (!result.isSuccess() || result.isEmpty()) return;
      _resultSubject.add(result);
    });
  }

  void dispose() {
    _timer.cancel();
  }
}

class _SubscriptionPlansUseCase {
  final _resultSubject = BehaviorSubject<SubscriptionPlansResult?>();
  ValueStream<SubscriptionPlansResult?> get stream => _resultSubject.stream;
  SubscriptionPlansResult? get _result => stream.valueOrNull;
  late final Timer _timer;
  _SubscriptionPlansUseCase() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchSubscriptionPlans();
    });
  }

  void fetchSubscriptionPlans({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _result?.peek() != null) {
        return;
      }

      if (_result != null) {
        _resultSubject.add(null);
      }

      final result = await locator<KwotData>()
          .subscriptionRepository
          .fetchSubscriptionPlans();

      _resultSubject.add(result);
    } catch (error) {
      final result = Result<Never>.error("Error: $error");
      _resultSubject.add(result);
    }
  }
  void dispose() {
    _timer.cancel();
  }
}
