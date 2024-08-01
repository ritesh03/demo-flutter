import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/misc/feedback/feedback_rating_prompt.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'feedback.model.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends PageState<FeedbackPage> {
  //=

  FeedbackModel get feedbackModel => context.read<FeedbackModel>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                child: _buildAppBar(),
                preferredSize: Size.fromHeight(ComponentSize.large.h)),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: ComponentInset.normal.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        SizedBox(height: ComponentInset.small.h),
                        _buildSubtitle(),
                        SizedBox(height: ComponentInset.normal.h),
                        _buildSummary(),
                        SizedBox(height: ComponentInset.medium.h),
                        _buildSmileys(),
                        SizedBox(height: ComponentInset.normal.h),
                        _buildEmailInput(),
                        SizedBox(height: ComponentInset.normal.h),
                        _buildFeedbackTextInput(),
                        const DashboardConfigAwareFooter(),
                      ],
                    )))));
  }

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      Button(
          text: LocaleResources.of(context).sendFeedback,
          type: ButtonType.text,
          height: ComponentSize.smaller.h,
          onPressed: _onSendButtonTapped),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildTitle() {
    return Text(LocaleResources.of(context).feedbackPageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle() {
    return Text(LocaleResources.of(context).feedbackPageSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSummary() {
    return Text(LocaleResources.of(context).feedbackPageSummary,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }

  Widget _buildSmileys() {
    return Selector<FeedbackModel, FeedbackSmiley>(
        selector: (_, model) => model.feedbackSmiley,
        builder: (_, selectedSmiley, __) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSmiley(
                    smiley: FeedbackSmiley.happy,
                    selected: FeedbackSmiley.happy == selectedSmiley),
                _buildSmiley(
                    smiley: FeedbackSmiley.average,
                    selected: FeedbackSmiley.average == selectedSmiley),
                _buildSmiley(
                    smiley: FeedbackSmiley.sad,
                    selected: FeedbackSmiley.sad == selectedSmiley),
              ]);
        });
  }

  Widget _buildSmiley({
    required FeedbackSmiley smiley,
    required bool selected,
  }) {
    final String assetPath;
    switch (smiley) {
      case FeedbackSmiley.happy:
        assetPath = Assets.iconFeedbackHappy;
        break;
      case FeedbackSmiley.average:
        assetPath = Assets.iconFeedbackAverage;
        break;
      case FeedbackSmiley.sad:
        assetPath = Assets.iconFeedbackSad;
        break;
    }

    return ScaleTap(
        onPressed: () => feedbackModel.onFeedbackSmileyChanged(smiley),
        child: AnimatedOpacity(
          opacity: selected ? 1.0 : 0.3,
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(assetPath, width: 100.r, height: 100.r),
        ));
  }

  Widget _buildEmailInput() {
    return Selector<FeedbackModel, Tuple2<bool, String?>>(
        selector: (_, model) =>
            Tuple2(model.canEditEmail, model.emailInputError),
        builder: (_, tuple, __) {
          final canEditEmail = tuple.item1;
          final error = tuple.item2;
          return TextInputField(
              controller: feedbackModel.emailInputController,
              enabled: canEditEmail,
              errorText: error,
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).emailInputHint,
              labelText: LocaleResources.of(context).emailInputLabel,
              onChanged: (text) => feedbackModel.onEmailInputChanged(text),
              keyboardType: TextInputType.emailAddress);
        });
  }

  Widget _buildFeedbackTextInput() {
    return TextInputField(
      controller: feedbackModel.feedbackTextInputController,
      height: 140.h,
      hintText: LocaleResources.of(context).feedbackTextInputHint,
      inputBoxCrossAxisAlignment: CrossAxisAlignment.start,
      inputBoxPadding: EdgeInsets.symmetric(vertical: ComponentInset.small.r),
      keyboardType: TextInputType.multiline,
      labelText: LocaleResources.of(context).feedbackTextInputLabel,
      maxLines: null,
      minLines: 5,
    );
  }

  /*
   * ACTIONS
   */

  // void _onSelectReasonButtonTapped() async {
  //   hideKeyboard(context);
  //
  //   final selectedContactReason = feedbackModel.selectedContactReason;
  //   final contactReasons = feedbackModel.contactReasonsResult?.peek();
  //   if (contactReasons == null || contactReasons.isEmpty) {
  //     return;
  //   }
  //
  //   final contactReason = await ContactReasonSelectionBottomSheet.show(context,
  //       reasons: contactReasons, selectedReason: selectedContactReason);
  //   if (contactReason != null && contactReason is ContactReason) {
  //     feedbackModel.updateSelectedContactReason(contactReason);
  //   }
  // }

  void _onSendButtonTapped() async {
    hideKeyboard(context);

    // show processing dialog
    showBlockingProgressDialog(context);

    // update profile
    feedbackModel.submitFeedback(context).then((result) async {
      // hide dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      final feedbackSmiley = feedbackModel.feedbackSmiley;
      await FeedbackRatingPromptBottomSheet.show(context, feedbackSmiley);

      DashboardNavigation.pop(context);
    });
  }
}
