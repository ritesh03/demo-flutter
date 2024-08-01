import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/photochooserselectionsheet/photo_chooser_selection_sheet.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/textfield/widget/verification_status.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/events/events.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/misc/address/countrypicker/country_picker.bottomsheet.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/profile/changepassword/change_password.page.dart';
import 'package:kwotmusic/features/profile/deleteaccount/delete_account_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/profile/editprofile/phoneverification/profile_phone_verification.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/prefs.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:kwotmusic/util/validation_util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'edit_profile.model.dart';
import 'emailverification/profile_email_verification.model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends PageState<EditProfilePage> {
  //=

  EditProfileModel get editProfileModel => context.read<EditProfileModel>();

  @override
  void initState() {
    super.initState();
    editProfileModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<EditProfileModel, Result<Profile>?>(
                selector: (_, model) => model.profileResult,
                builder: (_, result, __) {
                  if (result == null) {
                    return const LoadingIndicator();
                  }

                  if (!result.isSuccess()) {
                    return Center(
                        child: ErrorIndicator(
                            error: result.error(),
                            onTryAgain: () => editProfileModel.fetchProfile()));
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
      _buildSaveButton(),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildSaveButton() {
    return Selector<EditProfileModel, bool>(
        selector: (_, model) => model.canSave,
        builder: (_, canSave, __) {
          return Button(
              text: LocaleResources.of(context).save,
              type: ButtonType.text,
              enabled: canSave,
              height: ComponentSize.smaller.h,
              onPressed: _onSaveButtonTapped);
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
                SizedBox(height: ComponentInset.normal.h),
                _buildProfilePhotoSection(),
                SizedBox(height: ComponentInset.medium.h),
                _buildFirstNameInput(),
                SizedBox(height: ComponentInset.medium.h),
                _buildLastNameInput(),
                SizedBox(height: ComponentInset.medium.h),
                _buildEmailInput(),
                SizedBox(height: ComponentInset.medium.h),
                _buildPhoneNumberInput(),
                SizedBox(height: ComponentInset.medium.h),
                _buildChangePasswordButton(),
                SizedBox(height: ComponentInset.normal.h),
               _buildDeleteAccountButton(),
                const DashboardConfigAwareFooter()
              ],
            )));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).editProfilePageTitle,
            style: TextStyles.boldHeading2));
  }

  Widget _buildProfilePhotoSection() {
    final height = 64.h;
    return SizedBox(
        height: 64.h,
        child: Selector<EditProfileModel, String?>(
            selector: (_, model) => model.profilePhotoPath,
            builder: (_, profilePhotoPath, __) {
              return Row(children: [
                Photo.user(
                  profilePhotoPath,
                  options: PhotoOptions(
                    width: height,
                    height: height,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: ComponentInset.small.r),
                Button(
                    text: (profilePhotoPath != null)
                        ? LocaleResources.of(context).changePicture
                        : LocaleResources.of(context).addPicture,
                    type: ButtonType.text,
                    height: ComponentSize.normal.h,
                    onPressed: _onChangeProfilePhotoButtonTapped)
              ]);
            }));
  }

  Widget _buildFirstNameInput() {
    return Selector<EditProfileModel, String?>(
        selector: (_, model) => model.firstNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: editProfileModel.firstNameEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).firstNameInputHint,
            labelText: LocaleResources.of(context).firstNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) => editProfileModel.onFirstNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildLastNameInput() {
    return Selector<EditProfileModel, String?>(
        selector: (_, model) => model.lastNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: editProfileModel.lastNameEditingController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).lastNameInputHint,
            labelText: LocaleResources.of(context).lastNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) => editProfileModel.onLastNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildEmailInput() {
    return Selector<EditProfileModel, String?>(
        selector: (_, model) => model.emailInputError,
        builder: (_, error, __) {
          return TextInputField(
              controller: editProfileModel.emailEditingController,
              errorText: error,
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).emailInputHint,
              labelText: LocaleResources.of(context).emailInputLabel,
              onChanged: (text) => editProfileModel.onEmailInputChanged(text),
              keyboardType: TextInputType.emailAddress,
              suffixes: [_buildEmailVerificationButton()]);
        });
  }

  Widget _buildEmailVerificationButton() {
    return Selector<EditProfileModel, bool?>(
        selector: (context, model) => model.isEmailVerified(context),
        builder: (_, isEmailVerified, __) {
          return VerificationStatusWidget(
              verified: isEmailVerified,
              onVerifyTap: _onVerifyEmailButtonTapped);
        });
  }

  Widget _buildPhoneNumberInput() {
    return Selector<EditProfileModel, Tuple2<String?, Country?>>(
        selector: (_, model) =>
            Tuple2(model.phoneNumberInputError, model.selectedCountry),
        builder: (_, tuple, __) {
          final error = tuple.item1;
          final country = tuple.item2;

          return TextInputField(
              prefixes: [
                CountryCodeSelectorPrefix(
                    country: country, onPressed: _onCountryButtonTapped)
              ],
              controller: editProfileModel.phoneEditingController,
              errorText: error,
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).phoneNumberInputHint,
              keyboardType: TextInputType.phone,
              labelText: LocaleResources.of(context).phoneNumberInputLabel,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                LengthLimitingTextInputFormatter(
                    AppConfig.allowedPhoneNumberLength)
              ],
              onChanged: (text) =>
                  editProfileModel.onPhoneNumberInputChanged(text),
              suffixes: [_buildPhoneNumberVerificationButton()]);
        });
  }

  Widget _buildPhoneNumberVerificationButton() {
    return Selector<EditProfileModel, bool?>(
        selector: (context, model) => model.isPhoneNumberVerified(context),
        builder: (_, isPhoneNumberVerified, __) {
          return VerificationStatusWidget(
              verified: isPhoneNumberVerified,
              onVerifyTap: _onVerifyPhoneNumberButtonTapped);
        });
  }

  Widget _buildChangePasswordButton() {
    return Button(
        text: LocaleResources.of(context).changePassword,
        type: ButtonType.text,
        height: ComponentSize.normal.h,
        onPressed: _onChangePasswordButtonTapped);
  }

  Widget _buildDeleteAccountButton() {
    return AppIconTextButton(
        color: DynamicTheme.get(context).neutral10(),
        height: ComponentSize.smaller.h,
        iconPath: Assets.iconDelete,
        iconTextSpacing: ComponentInset.smaller.w,
        text: LocaleResources.of(context).deleteAccount,
        textStyle: TextStyles.boldHeading5,
        onPressed: _onDeleteAccountButtonTapped);
  }

  /*
   * ACTIONS
   */

  void _onVerifyEmailButtonTapped() async {
    hideKeyboard(context);

    final profile = editProfileModel.profile;
    if (profile == null) return;

    final request = editProfileModel.createEmailOtpRequest(context);
    if (request == null) {
      return;
    }

    final emailVerificationPendingText =
        LocaleResources.of(context).errorEmailVerificationPending;
    final resultArgs = await DashboardNavigation.pushNamed(
        context, Routes.profileEmailVerification,
        arguments: ProfileEmailVerificationArgs(
            email: request.email,
            emailVerificationPendingText: emailVerificationPendingText));

    if (!mounted) return;
    if (resultArgs != null &&
        resultArgs is ProfileEmailVerificationResultArgs) {
      if (resultArgs.verified) {
        editProfileModel.updateLocallyVerifiedEmail(
          email: resultArgs.email,
        );
      }
      editProfileModel.refreshProfile();
    }
  }

  void _onVerifyPhoneNumberButtonTapped() async {
    hideKeyboard(context);

    final profile = editProfileModel.profile;
    if (profile == null) return;

    final request = editProfileModel.createPhoneOtpRequest(context);
    if (request == null) {
      return;
    }

    final resultArgs = await DashboardNavigation.pushNamed(
        context, Routes.profilePhoneVerification,
        arguments: ProfilePhoneVerificationArgs(
          country: request.country,
          phoneNumber: request.phoneNumber,
        ));

    if (!mounted) return;
    if (resultArgs != null &&
        resultArgs is ProfilePhoneVerificationResultArgs) {
      if (resultArgs.verified) {
        editProfileModel.updateLocallyVerifiedPhoneNumber(
          country: resultArgs.country,
          phoneNumber: resultArgs.phoneNumber,
        );
      }
      editProfileModel.refreshProfile();
    }
  }

  void _onSaveButtonTapped() async {
    hideKeyboard(context);

    final profile = editProfileModel.profile;
    if (profile == null) return;

    // show processing dialog
    showBlockingProgressDialog(context);

    // update profile
    editProfileModel.updateProfile(context).then((result) {
      // hide dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      showDefaultNotificationBar(
          NotificationBarInfo.success(message: result.message));

      final updatedProfile = result.data();
      eventBus.fire(ProfileUpdatedEvent(updatedProfile));
      DashboardNavigation.pop(context, updatedProfile);
    });
  }

  void _onChangeProfilePhotoButtonTapped() async {
    hideKeyboard(context);

    final PhotoChooser? chooser = await PhotoChooserSelectionSheet.show(
      context,
      title: LocaleResources.of(context).updateProfilePicture,
    );

    if (!mounted) return;
    if (chooser != null) {
      editProfileModel.pickPhoto(chooser);
    }
  }

  void _onCountryButtonTapped() async {
    hideKeyboard(context);

    final selectedCountry = editProfileModel.selectedCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      editProfileModel.updateCountry(country);
    }
  }

  void _onChangePasswordButtonTapped() {
    hideKeyboard(context);

    final currentRouteName = obtainRoute(context)?.settings.name;
    final args = (currentRouteName != null)
        ? ChangePasswordPageArgs(sourceRouteName: currentRouteName)
        : null;
    DashboardNavigation.pushNamed(context, Routes.changePassword,
        arguments: args);
  }

  void _onDeleteAccountButtonTapped() async {
    hideKeyboard(context);

    final profile = editProfileModel.profile;
    if (profile == null) return;

    bool? shouldDelete =
        await DeleteAccountConfirmationBottomSheet.show(context);
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    // show processing dialog
    if (!mounted) return;
    showBlockingProgressDialog(context);

    // stop playback
    locator<AudioPlaybackActionsModel>().stopPlayback();

    // delete account
    final result = await locator<SessionModel>().deleteAccount();

    // hide dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
        NotificationBarInfo.error(message: result.error()),
      );
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    // go to onboarding page
     SharedPref.prefs!.clear();
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.onboarding, (route) => false);
  }
}
