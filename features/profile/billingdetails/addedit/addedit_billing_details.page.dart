import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/button/buttons.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/components/widgets/textfield/fomatter/uppercase_text_input_formatter.dart';
import 'package:kwotmusic/components/widgets/textfield/widget/verification_status.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/misc/address/countrypicker/country_picker.bottomsheet.dart';
import 'package:kwotmusic/features/misc/address/provincepicker/province_picker.bottomsheet.dart';
import 'package:kwotmusic/features/profile/editprofile/emailverification/profile_email_verification.model.dart';
import 'package:kwotmusic/features/profile/editprofile/phoneverification/profile_phone_verification.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:kwotmusic/util/validation_util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'addedit_billing_details.model.dart';

class AddEditBillingDetailsPage extends StatefulWidget {
  const AddEditBillingDetailsPage({Key? key}) : super(key: key);

  @override
  State<AddEditBillingDetailsPage> createState() =>
      _AddEditBillingDetailsPageState();
}

class _AddEditBillingDetailsPageState
    extends PageState<AddEditBillingDetailsPage> {
  //=

  AddEditBillingDetailsModel get addEditBillingDetailsModel =>
      context.read<AddEditBillingDetailsModel>();

  @override
  void initState() {
    super.initState();
    addEditBillingDetailsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<AddEditBillingDetailsModel, Result<Profile>?>(
                selector: (_, model) => model.profileResult,
                builder: (_, result, __) {
                  if (result == null) {
                    return const LoadingIndicator();
                  }

                  if (!result.isSuccess()) {
                    return Center(
                      child: ErrorIndicator(
                          error: result.error(),
                          onTryAgain: () =>
                              addEditBillingDetailsModel.fetchProfile()),
                    );
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
    return Selector<AddEditBillingDetailsModel, bool>(
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
    final localeResource = LocaleResources.of(context);
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: ComponentInset.normal.h),
                Row(children: [
                  Expanded(flex: 5, child: _buildFirstNameInput()),
                  SizedBox(width: ComponentInset.normal.w),
                  Expanded(flex: 6, child: _buildLastNameInput()),
                ]),
                SizedBox(height: ComponentInset.medium.h),

                // EMAIL
                _EmailInputField(
                  controller: addEditBillingDetailsModel.emailInputController,
                  localeResource: localeResource,
                  onChanged: addEditBillingDetailsModel.onEmailInputChanged,
                  onVerifyEmailButtonTap: _onVerifyEmailButtonTapped,
                ),
                SizedBox(height: ComponentInset.medium.h),
                _buildPhoneNumberInput(),
                SizedBox(height: ComponentInset.medium.h),
                _buildAddressLine1Input(),
                SizedBox(height: ComponentInset.medium.h),
                _buildAddressLine2Input(),
                SizedBox(height: ComponentInset.medium.h),
                Row(children: [
                  Expanded(child: _buildCountryDropdown()),
                  SizedBox(width: ComponentInset.normal.w),
                  Expanded(child: _buildProvinceDropdown()),
                ]),
                SizedBox(height: ComponentInset.medium.h),
                Row(children: [
                  Expanded(child: _buildCityInput()),
                  SizedBox(width: ComponentInset.normal.w),
                  Expanded(child: _buildPostalCodeInput()),
                ]),
                SizedBox(height: ComponentInset.medium.h),
               /* Row(children: [
                  Expanded(flex: 3, child: _buildCompanyNameInputField()),
                  SizedBox(width: ComponentInset.normal.w),
                  Expanded(flex: 2, child: _buildNationalIdInputField()),
                ]),*/
                const DashboardConfigAwareFooter(),
              ],
            )));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        alignment: Alignment.centerLeft,
        child: Text(LocaleResources.of(context).billingDetails,
            style: TextStyles.boldHeading2));
  }

  Widget _buildFirstNameInput() {
    return Selector<AddEditBillingDetailsModel, String?>(
        selector: (_, model) => model.firstNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: addEditBillingDetailsModel.firstNameInputController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).firstNameInputHint,
            labelText: LocaleResources.of(context).firstNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) =>
                addEditBillingDetailsModel.onFirstNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildLastNameInput() {
    return Selector<AddEditBillingDetailsModel, String?>(
        selector: (_, model) => model.lastNameInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: addEditBillingDetailsModel.lastNameInputController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).lastNameInputHint,
            labelText: LocaleResources.of(context).lastNameInputLabel,
            inputFormatters: ValidationUtil.text.nameInputFormatters,
            onChanged: (text) =>
                addEditBillingDetailsModel.onLastNameInputChanged(text),
            textCapitalization: ValidationUtil.text.nameInputCapitalization,
          );
        });
  }

  Widget _buildPhoneNumberInput() {
    return Selector<AddEditBillingDetailsModel, Tuple2<String?, Country?>>(
        selector: (_, model) => Tuple2(
            model.phoneNumberInputError, model.selectedPhoneNumberCountry),
        builder: (_, tuple, __) {
          final error = tuple.item1;
          final country = tuple.item2;

          return TextInputField(
              prefixes: [
                CountryCodeSelectorPrefix(
                    country: country,
                    onPressed: _onSelectPhoneNumberCountryButtonTapped)
              ],
              controller: addEditBillingDetailsModel.phoneNumberInputController,
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
              onChanged: (text) => addEditBillingDetailsModel.onPhoneNumberInputChanged(text),
            //  suffixes: [_buildPhoneNumberVerificationButton()]

          );
        });
  }

  Widget _buildPhoneNumberVerificationButton() {
    return Selector<AddEditBillingDetailsModel, bool?>(
        selector: (context, model) => model.isPhoneNumberVerified(context),
        builder: (_, isPhoneNumberVerified, __) {
          return VerificationStatusWidget(
              verified: isPhoneNumberVerified,
              onVerifyTap: _onVerifyPhoneNumberButtonTapped);
        });
  }

  Widget _buildAddressLine1Input() {
    return Selector<AddEditBillingDetailsModel, String?>(
        selector: (_, model) => model.addressLine1InputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: addEditBillingDetailsModel.addressLine1InputController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).addressLine1InputHint,
            labelText: LocaleResources.of(context).addressLine1InputLabel,
            onChanged: (text) =>
                addEditBillingDetailsModel.onAddressLine1InputChanged(text),
          );
        });
  }

  Widget _buildAddressLine2Input() {
    return TextInputField(
      controller: addEditBillingDetailsModel.addressLine2InputController,
      height: ComponentSize.large.h,
      hintText: LocaleResources.of(context).addressLine2InputHint,
      labelText: LocaleResources.of(context).addressLine2InputLabel,
    );
  }

  Widget _buildCountryDropdown() {
    return Selector<AddEditBillingDetailsModel, Tuple2<Country?, String?>>(
        selector: (_, model) => Tuple2(
              model.selectedBillingCountry,
              model.billingCountryError,
            ),
        builder: (_, tuple, __) {
          final country = tuple.item1;
          final error = tuple.item2;

          return DropDownButton(
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).select,
              inputText: country?.name,
              errorText: error,
              labelText: LocaleResources.of(context).country,
              onTap: _onSelectBillingCountryButtonTapped);
        });
  }

  Widget _buildProvinceDropdown() {
    return Selector<AddEditBillingDetailsModel,
            Tuple3<Country?, Province?, String?>>(
        selector: (_, model) => Tuple3(
              model.selectedBillingCountry,
              model.selectedBillingProvince,
              model.billingProvinceError,
            ),
        builder: (_, tuple, __) {
          final country = tuple.item1;
          final province = tuple.item2;
          final error = tuple.item3;
          return DropDownButton(
              height: ComponentSize.large.h,
              hintText: LocaleResources.of(context).select,
              inputText: province?.name,
              errorText: error,
              enabled: country != null,
              labelText: LocaleResources.of(context).provinceState,
              onTap: _onSelectBillingProvinceButtonTapped);
        });
  }

  Widget _buildCityInput() {
    return Selector<AddEditBillingDetailsModel, String?>(
        selector: (_, model) => model.cityInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: addEditBillingDetailsModel.cityInputController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).billingCityInputHint,
            inputFormatters: [LengthLimitingTextInputFormatter(32)],
            labelText: LocaleResources.of(context).billingCityInputLabel,
            onChanged: addEditBillingDetailsModel.onCityInputChanged,
            textCapitalization: TextCapitalization.words,
          );
        });
  }

  Widget _buildPostalCodeInput() {
    return Selector<AddEditBillingDetailsModel, String?>(
        selector: (_, model) => model.postalCodeInputError,
        builder: (_, error, __) {
          return TextInputField(
            controller: addEditBillingDetailsModel.postalCodeInputController,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: LocaleResources.of(context).postalCodeInputHint,
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              UpperCaseTextInputFormatter(),
            ],
            labelText: LocaleResources.of(context).postalCodeInputLabel,
            onChanged: (text) =>
                addEditBillingDetailsModel.onPostalCodeInputChanged(text),
          );
        });
  }

  Widget _buildCompanyNameInputField() {
    return TextInputField(
      controller: addEditBillingDetailsModel.companyNameInputController,
      height: ComponentSize.large.h,
      hintText: LocaleResources.of(context).companyNameInputHint,
      inputFormatters: [LengthLimitingTextInputFormatter(48)],
      labelText: LocaleResources.of(context).companyNameInputLabel,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildNationalIdInputField() {
    return TextInputField(
        controller: addEditBillingDetailsModel.nationalIdInputController,
        height: ComponentSize.large.h,
        hintText: LocaleResources.of(context).nationalIdInputHint,
        labelText: LocaleResources.of(context).nationalIdInputLabel,
        inputFormatters: [
          LengthLimitingTextInputFormatter(48),
          UpperCaseTextInputFormatter(),
          FilteringTextInputFormatter.allow(RegExp("[A-Z0-9]")),
        ]);
  }

  /*
   * ACTIONS
   */

  void _onSelectPhoneNumberCountryButtonTapped() async {
    hideKeyboard(context);

    final selectedCountry =
        addEditBillingDetailsModel.selectedPhoneNumberCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      addEditBillingDetailsModel.updatePhoneNumberCountry(country);
    }
  }

  void _onSelectBillingCountryButtonTapped() async {
    hideKeyboard(context);

    final selectedCountry = addEditBillingDetailsModel.selectedBillingCountry;
    final country =
        await CountryPickerBottomSheet.show(context, selectedCountry);

    if (!mounted) return;
    if (country != null) {
      addEditBillingDetailsModel.updateBillingCountry(country);
    }
  }

  void _onSelectBillingProvinceButtonTapped() async {
    hideKeyboard(context);

    final selectedCountry = addEditBillingDetailsModel.selectedBillingCountry;
    if (selectedCountry == null) {
      showDefaultNotificationBar(NotificationBarInfo.error(
          message: LocaleResources.of(context).errorSelectCountry));
      return;
    }

    final selectedProvince = addEditBillingDetailsModel.selectedBillingProvince;
    final province = await ProvincePickerBottomSheet.show(
      context,
      countryId: selectedCountry.id,
      selectedProvince: selectedProvince,
    );

    if (!mounted) return;
    if (province != null) {
      addEditBillingDetailsModel.updateBillingProvince(province);
    }
  }

  void _onVerifyEmailButtonTapped() async {
    hideKeyboard(context);

    final profile = addEditBillingDetailsModel.profile;
    if (profile == null) return;

    final request = addEditBillingDetailsModel.createEmailOtpRequest(context);
    if (request == null) return;

    final emailVerificationPendingText =
        LocaleResources.of(context).errorEmailVerificationPending;
    final resultArgs = await DashboardNavigation.pushNamed(
      context,
      Routes.profileEmailVerification,
      arguments: ProfileEmailVerificationArgs(
        email: request.email,
        emailVerificationPendingText: emailVerificationPendingText,
      ),
    );

    if (!mounted) return;
    if (resultArgs != null &&
        resultArgs is ProfileEmailVerificationResultArgs &&
        resultArgs.verified) {
      if (!mounted) return;
      addEditBillingDetailsModel.updateLocallyVerifiedEmail(
        email: resultArgs.email,
      );
    }
  }

  void _onVerifyPhoneNumberButtonTapped() async {
    hideKeyboard(context);

    final profile = addEditBillingDetailsModel.profile;
    if (profile == null) return;

    final request = addEditBillingDetailsModel.createPhoneOtpRequest(context);
    if (request == null) return;

    final resultArgs = await DashboardNavigation.pushNamed(
      context,
      Routes.profilePhoneVerification,
      arguments: ProfilePhoneVerificationArgs(
        country: request.country,
        phoneNumber: request.phoneNumber,
      ),
    );
    if (resultArgs != null &&
        resultArgs is ProfilePhoneVerificationResultArgs &&
        resultArgs.verified) {
      if (!mounted) return;
      addEditBillingDetailsModel.updateLocallyVerifiedPhoneNumber(
        country: resultArgs.country,
        phoneNumber: resultArgs.phoneNumber,
      );
    }
  }

  void _onSaveButtonTapped() async {
    hideKeyboard(context);

    final profile = addEditBillingDetailsModel.profile;
    if (profile == null) return;

    // show processing dialog
    showBlockingProgressDialog(context);

    // update billing detail
    addEditBillingDetailsModel.updateBillingDetail(context).then((result) {
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
      DashboardNavigation.pop(context, true);
    });
  }
}

class _EmailInputField extends StatelessWidget {
  const _EmailInputField({
    Key? key,
    required this.controller,
    required this.localeResource,
    required this.onChanged,
    required this.onVerifyEmailButtonTap,
  }) : super(key: key);

  final TextEditingController controller;
  final TextLocaleResource localeResource;
  final Function(String) onChanged;
  final VoidCallback onVerifyEmailButtonTap;

  @override
  Widget build(BuildContext context) {
    return Selector<AddEditBillingDetailsModel, String?>(
      selector: (_, model) => model.emailInputError,
      builder: (_, error, child) {
        return TextInputField(
            controller: controller,
            errorText: error,
            height: ComponentSize.large.h,
            hintText: localeResource.emailInputHint,
            labelText: localeResource.emailInputLabel,
            onChanged: onChanged,
            keyboardType: TextInputType.emailAddress,
            suffixes: [child!]);
      },
      child: Selector<AddEditBillingDetailsModel, bool?>(
          selector: (context, model) => model.isEmailVerified(context),
          builder: (_, isEmailVerified, __) {
            return VerificationStatusWidget(
              verified: isEmailVerified,
              onVerifyTap: onVerifyEmailButtonTap,
            );
          }),
    );
  }
}
