import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'contact.model.dart';
import 'reason/contact_reason_selection.bottomsheet.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends PageState<ContactPage> {
  //=

  ContactModel get contactModel => context.read<ContactModel>();

  @override
  void initState() {
    super.initState();
    contactModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                child: _buildAppBar(),
                preferredSize: Size.fromHeight(ComponentSize.large.h)),
            body: Selector<ContactModel, Result<List<ContactReason>>?>(
                selector: (_, model) => model.contactReasonsResult,
                builder: (_, result, __) {
                  if (result == null) {
                    return const LoadingIndicator();
                  }

                  if (!result.isSuccess()) {
                    return Center(
                        child: ErrorIndicator(
                      error: result.error(),
                      onTryAgain: () => contactModel.fetchContactReasons(),
                    ));
                  }

                  return _buildContent();
                })));
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
      _buildSendButton(),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildSendButton() {
    return Selector<ContactModel, bool>(
        selector: (_, model) => model.canSubmitRequest,
        builder: (_, canSend, __) {
          return Button(
              text: LocaleResources.of(context).send,
              type: ButtonType.text,
              enabled: canSend,
              height: ComponentSize.smaller.h,
              onPressed: _onSendButtonTapped);
        });
  }

  Widget _buildContent() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: ComponentInset.medium.h),
                _buildEmailInput(),
                SizedBox(height: ComponentInset.normal.h),
                _buildContactReasonsDropdown(),
                SizedBox(height: ComponentInset.normal.h),
                _buildDescriptionInput(),
                const DashboardConfigAwareFooter(),
              ],
            )));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).contactPageTitle,
            style: TextStyles.boldHeading2));
  }

  Widget _buildEmailInput() {
    return Selector<ContactModel, Tuple2<bool, String?>>(
        selector: (_, model) =>
            Tuple2(model.canEditEmail, model.emailInputError),
        builder: (_, tuple, __) {
          final canEditEmail = tuple.item1;
          final error = tuple.item2;
          return TextInputField(
              controller: contactModel.emailInputController,
              enabled: canEditEmail,
              errorText: error,
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).emailInputHint,
              labelText: LocaleResources.of(context).emailInputLabel,
              onChanged: (text) => contactModel.onEmailInputChanged(text),
              keyboardType: TextInputType.emailAddress);
        });
  }

  Widget _buildContactReasonsDropdown() {
    return Selector<ContactModel, Tuple2<ContactReason?, String?>>(
        selector: (_, model) =>
            Tuple2(model.selectedContactReason, model.contactReasonInputError),
        builder: (_, tuple, __) {
          final selectedContactReason = tuple.item1;
          final error = tuple.item2;
          return DropDownButton(
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).contactReasonSelectionHint,
              inputText: selectedContactReason?.title,
              errorText: error,
              labelText:
                  LocaleResources.of(context).contactReasonSelectionLabel,
              onTap: _onSelectReasonButtonTapped);
        });
  }

  Widget _buildDescriptionInput() {
    return Selector<ContactModel, String?>(
        selector: (_, model) => model.descriptionInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: contactModel.descriptionInputController,
            errorText: error,
            height: 140.h,
            hintText: LocaleResources.of(context).contactRequestDescriptionHint,
            inputBoxCrossAxisAlignment: CrossAxisAlignment.start,
            inputBoxPadding:
                EdgeInsets.symmetric(vertical: ComponentInset.small.r),
            keyboardType: TextInputType.multiline,
            labelText:
                LocaleResources.of(context).contactRequestDescriptionLabel,
            maxLines: null,
            minLines: 5,
            onChanged: (text) => contactModel.onDescriptionInputChanged(text),
          );
        });
  }

  /*
   * ACTIONS
   */

  void _onSelectReasonButtonTapped() async {
    hideKeyboard(context);

    final selectedContactReason = contactModel.selectedContactReason;
    final contactReasons = contactModel.contactReasonsResult?.peek();
    if (contactReasons == null || contactReasons.isEmpty) {
      return;
    }

    final contactReason = await ContactReasonSelectionBottomSheet.show(context,
        reasons: contactReasons, selectedReason: selectedContactReason);
    if (contactReason != null && contactReason is ContactReason) {
      contactModel.updateSelectedContactReason(contactReason);
    }
  }

  void _onSendButtonTapped() async {
    hideKeyboard(context);

    // show processing dialog
    showBlockingProgressDialog(context);

    // update profile
    contactModel.submitContactRequest(context).then((result) {
      // hide dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      final message = result.message;
      if (message != null) {
        showDefaultNotificationBar(
          NotificationBarInfo.success(message: message),
        );
      }

      DashboardNavigation.pop(context);
    });
  }
}
