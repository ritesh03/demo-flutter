import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/looping_page_view.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/profile/subscriptions/cancel/cancel_subscription_plan_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/profile/subscriptions/planchooser/choose_subscription_plan.bottomsheet.dart';
import 'package:kwotmusic/features/profile/subscriptions/purchase/step1preview/subscription_plan_selection_preview.model.dart';
import 'package:kwotmusic/features/profile/subscriptions/widget/subscription_plan.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import '../../../../util/date_time_methods.dart';
import '../subscription_detail.model.dart';
import '../subscription_detail.model.dart';
import 'manage_subscription.model.dart';
import 'manage_subscription.page.actions.dart';

class ManageSubscriptionPage extends StatefulWidget {
  const ManageSubscriptionPage({Key? key}) : super(key: key);

  @override
  State<ManageSubscriptionPage> createState() => _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState extends PageState<ManageSubscriptionPage>
    implements ManageSubscriptionPageActionsListener {
  //=
  late final LoopingPageController _loopingPageController;
  late final ScrollController _scrollController;

  ManageSubscriptionModel get _subscriptionModel => context.read<ManageSubscriptionModel>();

  @override
  void initState() {
    super.initState();
    _loopingPageController = LoopingPageController();
    _scrollController = ScrollController();
    _subscriptionModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);

    return SafeArea(
      child: Scaffold(
        body: PageTitleBarWrapper(
          barHeight: ComponentSize.large.r,
          title: PageTitleBarText(
              text: localeResource.mySubscription,
              color: DynamicTheme.get(context).white(),
              onTap: _scrollController.animateToTop),
          centerTitle: true,
          actions: const [],
          child: _PageContent(
            controller: _scrollController,
            localeResource: localeResource,
            listener: this,
          ),
        ),
      ),
    );
  }

  @override
  void onActiveSubscriptionPlanTap(SubscriptionPlan plan) {}

  @override
  void onRefreshActiveSubscriptionPlanTap() {
    _subscriptionModel.refreshActiveSubscription();
  }

  @override
  LoopingPageController getSubscriptionPlansPageController() {
    return _loopingPageController;
  }

  @override
  void onSubscriptionPlanTap(SubscriptionPlan plan) {
    DashboardNavigation.pushNamed(
      context,
      Routes.subscriptionPlanSelectionPreview,
      arguments: SubscriptionPlanSelectionPreviewArgs(selectedPlan: plan, planName: _subscriptionModel.subscriptionDetailResult!.data().plan?.name??""),
    ).then((value) {
      if(value == true){
        _subscriptionModel.init();
      }
    });
  }

  @override
  void onRefreshSubscriptionPlansTap() {
    _subscriptionModel.refreshSubscriptionPlans();
  }

  @override
  void onChangeSubscriptionPlanTap() async {
    final subscriptionDetail = _subscriptionModel.subscriptionDetail;
    if (subscriptionDetail == null || subscriptionDetail.activation == null) {
      return;
    }

    final currentPlan = subscriptionDetail.plan;
    final selectedPlan = await ChooseSubscriptionPlanBottomSheet.show(
      context,
      chosenSubscriptionPlanId: currentPlan?.id,
    );
    if (!mounted) return;
    if (selectedPlan == null || selectedPlan.id == currentPlan?.id) {
      return;
    }

    onSubscriptionPlanTap(selectedPlan);
  }

  @override
  void onCancelSubscriptionPlanTap() async {
    final subscriptionDetail = _subscriptionModel.subscriptionDetail;
    if (subscriptionDetail == null || subscriptionDetail.activation == null) {
      return;
    }

    final activation = subscriptionDetail.activation!;
    if (activation.status != SubscriptionStatus.active) return;

    final shouldCancel =
        await CancelSubscriptionPlanConfirmationBottomSheet.show(context,
            planEndDate: DateConvertor.dateForBottomSheet(activation.endDate.toString()) ?? "", isFromArtist: false, onTapCancel: () { RootNavigation.pop(context, true); });
    if (!mounted) return;
    if (shouldCancel == null || !shouldCancel) {
      return;
    }

    showBlockingProgressDialog(context);
    final result = await _subscriptionModel.cancelSubscription();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));
  }

  @override
  void onRenewSubscriptionPlanTap() {
    final subscriptionDetail = _subscriptionModel.subscriptionDetail;
    if (subscriptionDetail == null || subscriptionDetail.activation == null) {
      return;
    }

    final plan = subscriptionDetail.plan;
    DashboardNavigation.pushNamed(
      context,
      Routes.subscriptionPlanSelectionPreview,
      arguments: SubscriptionPlanSelectionPreviewArgs(selectedPlan: plan, planName: ''),
    );
  }
}

class _PageTopBar extends StatelessWidget {
  const _PageTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
    ]);
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({
    Key? key,
    required this.controller,
    required this.localeResource,
    required this.listener,
  }) : super(key: key);

  final ScrollController controller;
  final TextLocaleResource localeResource;
  final ManageSubscriptionPageActionsListener listener;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _PageTopBar(),
        _ActiveSubscriptionPlanWidget(listener: listener),
        /*Padding(
          padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
          child: _SubscriptionDetailOptionsWidget(
              localeResource: localeResource, listener: listener),
        ),*/
        _SubscriptionPlanChooserWidget(listener: listener),
      ]),
    );
  }
}

class _ActiveSubscriptionPlanWidget extends StatelessWidget {
  const _ActiveSubscriptionPlanWidget({
    Key? key,
    required this.listener,
  }) : super(key: key);

  final ManageSubscriptionPageActionsListener listener;

  @override
  Widget build(BuildContext context) {
    final topIndicatorMarginValue = 120.r;
    final localeResource = LocaleResources.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(text: localeResource.subscriptionYourPlan),
      SizedBox(height: ComponentInset.normal.r),
      Selector<ManageSubscriptionModel, Result<SubscriptionDetail>?>(
        selector: (_, model) => model.subscriptionDetailResult,
        builder: (_, result, __) {
          if (result == null) {
            return Padding(
              padding: EdgeInsets.only(top: topIndicatorMarginValue),
              child: const LoadingIndicator(),
            );
          }

          if (!result.isSuccess() || result.isEmpty()) {
            return Padding(
              padding: EdgeInsets.only(top: topIndicatorMarginValue),
              child: ErrorIndicator(
                error: result.error(),
                onTryAgain: listener.onRefreshActiveSubscriptionPlanTap,
              ),
            );
          }

          final subscriptionDetail = result.data();
          return SubscriptionPlanWidget(
            plan: subscriptionDetail?.plan,
            margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            onTap: listener.onActiveSubscriptionPlanTap,
          );
        },
      ),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}

class _SubscriptionDetailOptionsWidget extends StatelessWidget {
  const _SubscriptionDetailOptionsWidget({
    Key? key,
    required this.localeResource,
    required this.listener,
  }) : super(key: key);

  final TextLocaleResource localeResource;
  final ManageSubscriptionPageActionsListener listener;

  @override
  Widget build(BuildContext context) {
    return Selector<ManageSubscriptionModel, SubscriptionDetail?>(
        selector: (_, model) => model.subscriptionDetail,
        builder: (_, subscriptionDetail, __) {
          if (subscriptionDetail == null ||
              subscriptionDetail.activation == null) {
            return const SizedBox.shrink();
          }

          final activation = subscriptionDetail.activation!;
          final status = activation.status;

          final active = (status == SubscriptionStatus.active);
          final cancellable = active;
          final cancelled = (status == SubscriptionStatus.cancelled);
          final renewable = cancelled;
          final upgradable = subscriptionDetail.upgradable;

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SUBSCRIPTION RENEWAL DATE
                if (active)
                  SubscriptionAutoRenewalDateWarning(
                    date: activation.renewalDate??DateTime.now(),
                    localeResource: localeResource,
                  ),
                if (cancelled)
                  _SubscriptionActiveUntilDateWarning(
                    date: activation.endDate,
                    localeResource: localeResource,
                  ),
                SizedBox(height: ComponentInset.normal.r),

                // CHANGE PLAN (if upgradable)
                if (!cancelled && upgradable)
                  Button(
                      height: ComponentSize.smaller.r,
                      onPressed: listener.onChangeSubscriptionPlanTap,
                      text: localeResource.subscriptionChangePlan,
                      type: ButtonType.text),
                SizedBox(height: ComponentInset.normal.r),

                // CANCEL SUBSCRIPTION (if active)
                if (cancellable)
                  _CancelSubscriptionButton(
                    text: localeResource.cancelSubscription,
                    onTap: listener.onCancelSubscriptionPlanTap,
                  ),

                // RENEW SUBSCRIPTION (if cancelled)
                if (renewable)
                  _RenewSubscriptionButton(
                    text: localeResource.renewSubscription,
                    onTap: listener.onRenewSubscriptionPlanTap,
                  ),
              ]);
        });
  }
}

class _SubscriptionPlanChooserWidget extends StatelessWidget {
  const _SubscriptionPlanChooserWidget({
    Key? key,
    required this.listener,
  }) : super(key: key);

  final ManageSubscriptionPageActionsListener listener;

  @override
  Widget build(BuildContext context) {
    final localeResource = LocaleResources.of(context);

    return Selector<ManageSubscriptionModel, Result<List<SubscriptionPlan>>?>(
      selector: (_, model) => model.subscriptionPlansResult,
      builder: (_, result, __) {
        final isResultEmpty = (result != null && result.isEmpty());
        if (isResultEmpty) return const SizedBox.shrink();

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle(text: localeResource.subscriptionChooseYourPremium),
          SizedBox(height: ComponentInset.normal.r),
          _SubscriptionPlansResultWidget(listener: listener, result: result),
        ]);
      },
    );
  }
}

class _SubscriptionPlansResultWidget extends StatelessWidget {
  const _SubscriptionPlansResultWidget({
    Key? key,
    required this.listener,
    required this.result,
  }) : super(key: key);

  final ManageSubscriptionPageActionsListener listener;
  final Result<List<SubscriptionPlan>>? result;

  @override
  Widget build(BuildContext context) {
    final topIndicatorMarginValue = 40.r;
    final localeResource = LocaleResources.of(context);

    final result = this.result;
    if (result == null) {
      return Padding(
        padding: EdgeInsets.only(top: topIndicatorMarginValue),
        child: const LoadingIndicator(),
      );
    }

    if (!result.isSuccess()) {
      return Padding(
        padding: EdgeInsets.only(top: topIndicatorMarginValue),
        child: ErrorIndicator(
          error: result.error(),
          onTryAgain: listener.onRefreshSubscriptionPlansTap,
        ),
      );
    }

    final plans = result.data();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SubscriptionPlansListWidget(
        loopingPageController: listener.getSubscriptionPlansPageController(),
        plans: plans,
        onTap: listener.onSubscriptionPlanTap,
      ),
      SizedBox(height: ComponentInset.normal.r),
      _SectionNote(text: localeResource.subscriptionPlanAutoRenewalNote),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }
}

class _SubscriptionPlansListWidget extends StatelessWidget {
  const _SubscriptionPlansListWidget({
    Key? key,
    required this.loopingPageController,
    required this.plans,
    required this.onTap,
  }) : super(key: key);

  final LoopingPageController loopingPageController;
  final List<SubscriptionPlan> plans;
  final Function(SubscriptionPlan) onTap;

  @override
  Widget build(BuildContext context) {
    final height = 272.r;
    final pageSpacing = ComponentInset.small.r;

    return SizedBox(
        height: height,
        child: LoopingPageView(
          controller: loopingPageController,
          itemCount: plans.length,
          itemBuilder: (_, index) {
            final plan = plans[index];
            return SubscriptionPlanWidget(
              plan: plan,
              margin: EdgeInsets.symmetric(horizontal: pageSpacing),
              maxHeight: height,
              onTap: onTap,
              childHeight: ComponentSize.small.r,
              child: Button(
                width: double.infinity,
                height: ComponentSize.small.r,
                onPressed: () => onTap(plan),
                text:
                    LocaleResources.of(context).subscriptionStartPurchasePrompt,
                type: ButtonType.primary,
              ),
            );
          },
        ));
  }
}

class _CancelSubscriptionButton extends StatelessWidget {
  const _CancelSubscriptionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconTextButton(
        color: DynamicTheme.get(context).neutral10(),
        height: ComponentSize.smaller.r,
        iconPath: Assets.iconCrossBold,
        iconSize: ComponentSize.smaller.r,
        iconTextSpacing: ComponentInset.smaller.w,
        overwriteTextColor: false,
        text: text,
        textStyle: TextStyles.boldHeading5
            .copyWith(color: DynamicTheme.get(context).white()),
        onPressed: onTap);
  }
}

class _RenewSubscriptionButton extends StatelessWidget {
  const _RenewSubscriptionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
        width: double.infinity,
        height: ComponentSize.large.r,
        onPressed: onTap,
        text: text,
        type: ButtonType.primary);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading2
              .copyWith(color: DynamicTheme.get(context).white())),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Text(text,
          style: TextStyles.heading5
              .copyWith(color: DynamicTheme.get(context).neutral10()),
          textAlign: TextAlign.left),
    );
  }
}

class SubscriptionAutoRenewalDateWarning extends StatelessWidget {
  const SubscriptionAutoRenewalDateWarning({
    Key? key,
    required this.date,
    required this.localeResource,
    this.textAlign,
  }) : super(key: key);

  final DateTime date;
  final TextLocaleResource localeResource;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final dateText = date.toDefaultDateFormat();
    List<String> textParts = localeResource
        .subscriptionAutoRenewalDateMessage(dateText)
        .split(dateText);
    if (textParts.length != 2) {
      return const SizedBox.shrink();
    }

    final textColor = DynamicTheme.get(context).white();
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(
          text: textParts[0],
          style: TextStyles.body.copyWith(color: textColor),
          children: <TextSpan>[
            TextSpan(
                text: dateText,
                style: TextStyles.boldBody.copyWith(color: textColor)),
            TextSpan(text: textParts[1]),
          ]),
    );
  }
}

class _SubscriptionActiveUntilDateWarning extends StatelessWidget {
  const _SubscriptionActiveUntilDateWarning({
    Key? key,
    required this.date,
    required this.localeResource,
  }) : super(key: key);

  final DateTime date;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    final dateText = date.toDefaultDateFormat();
    List<String> textParts = localeResource
        .subscriptionCancelledButActiveUntilDateMessage(dateText)
        .split(dateText);
    if (textParts.length != 2) {
      return const SizedBox.shrink();
    }

    final textColor = DynamicTheme.get(context).white();
    return RichText(
      text: TextSpan(
          text: textParts[0],
          style: TextStyles.body.copyWith(color: textColor),
          children: <TextSpan>[
            TextSpan(
                text: dateText,
                style: TextStyles.boldBody.copyWith(color: textColor)),
            TextSpan(text: textParts[1]),
          ]),
    );
  }
}
