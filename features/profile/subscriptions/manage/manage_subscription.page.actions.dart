import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/widgets/looping_page_view.dart';

abstract class ManageSubscriptionPageActionsListener {
  void onActiveSubscriptionPlanTap(SubscriptionPlan plan);

  void onRefreshActiveSubscriptionPlanTap();

  LoopingPageController getSubscriptionPlansPageController();

  void onSubscriptionPlanTap(SubscriptionPlan plan);

  void onRefreshSubscriptionPlansTap();

  void onChangeSubscriptionPlanTap();

  void onCancelSubscriptionPlanTap();

  void onRenewSubscriptionPlanTap();
}
