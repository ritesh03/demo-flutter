import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class EditBillingDetailsArgs {
  final BillingDetail billingDetail;

  EditBillingDetailsArgs({required this.billingDetail});
}

class AddEditBillingDetailsModel with ChangeNotifier {
  //=

  final BillingDetail? targetBillingDetail;

  AddEditBillingDetailsModel({
    EditBillingDetailsArgs? args,
  }) : targetBillingDetail = args?.billingDetail;

  void init() {
    fetchProfile();
  }

  @override
  void dispose() {
    _profileOp?.cancel();
    _profileOp = null;

    _updateBillingDetailOp?.cancel();
    _updateBillingDetailOp = null;
    super.dispose();
  }

  /*
   * PROFILE
   */

  async.CancelableOperation<Result<Profile>>? _profileOp;
  Result<Profile>? profileResult;

  String? _locallyVerifiedEmail;
  Country? _locallyVerifiedCountry;
  String? _locallyVerifiedPhoneNumber;

  Profile? get profile => profileResult?.peek();

  Country? _selectedPhoneNumberCountry;

  Country? get selectedPhoneNumberCountry => _selectedPhoneNumberCountry;

  Country? _selectedBillingCountry;

  Country? get selectedBillingCountry =>
      _selectedBillingCountry ?? profile?.country;

  Province? _selectedBillingProvince;

  Province? get selectedBillingProvince => _selectedBillingProvince;

  bool get canSave {
    final profileResult = this.profileResult;
    return profileResult != null && profileResult.isSuccess();
  }

  Future<void> fetchProfile() async {
    try {
      // Cancel current operation (if any)
      _profileOp?.cancel();

      if (profileResult != null) {
        profileResult = null;
        notifyListeners();
      }

      // Create Request
      _profileOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchProfile());

      // Wait for result
      final result = await _profileOp?.value;
      if (result != null && result.isSuccess()) {
        final profile = result.data();

        final billingDetail = targetBillingDetail;
        firstNameInputController.text =
            billingDetail?.firstName ?? profile.firstName;

        lastNameInputController.text =
            billingDetail?.lastName ?? profile.lastName;

        emailInputController.text = profile.email ?? "";

        phoneNumberInputController.text = profile.phoneNumber ?? "";
        _selectedPhoneNumberCountry = profile.country;

        if (billingDetail != null) {
          addressLine1InputController.text = billingDetail.addressLine1;
          addressLine2InputController.text = billingDetail.addressLine2 ?? "";

          cityInputController.text = billingDetail.city??"";
          _selectedBillingCountry = billingDetail.country;
          _selectedBillingProvince = billingDetail.province;

          postalCodeInputController.text = billingDetail.postalCode;
          companyNameInputController.text = billingDetail.companyName ?? "";
          nationalIdInputController.text = billingDetail.nationalId ?? "";
        }
      }
      profileResult = result;
    } catch (error) {
      profileResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  /*
   * ADD / EDIT BILLING DETAIL
   */

  TextEditingController firstNameInputController = TextEditingController();
  TextEditingController lastNameInputController = TextEditingController();
  TextEditingController emailInputController = TextEditingController();
  TextEditingController phoneNumberInputController = TextEditingController();
  TextEditingController addressLine1InputController = TextEditingController();
  TextEditingController addressLine2InputController = TextEditingController();
  TextEditingController cityInputController = TextEditingController();
  TextEditingController postalCodeInputController = TextEditingController();

  TextEditingController companyNameInputController = TextEditingController();
  TextEditingController nationalIdInputController = TextEditingController();

  // First Name Input & Error

  String? _firstNameInputError;

  String? get firstNameInputError => _firstNameInputError;

  void onFirstNameInputChanged(String text) {
    _notifyFirstNameInputError(null);
  }

  void _notifyFirstNameInputError(String? error) {
    _firstNameInputError = error;
    notifyListeners();
  }

  // Last Name Input & Error

  String? _lastNameInputError;

  String? get lastNameInputError => _lastNameInputError;

  void onLastNameInputChanged(String text) {
    _notifyLastNameInputError(null);
  }

  void _notifyLastNameInputError(String? error) {
    _lastNameInputError = error;
    notifyListeners();
  }

  // Address Selection

  String? _billingCountryError;

  String? get billingCountryError => _billingCountryError;

  String? _billingProvinceError;

  String? get billingProvinceError => _billingProvinceError;

  void updatePhoneNumberCountry(Country country) {
    _selectedPhoneNumberCountry = country;
    _phoneNumberInputError = null;
    notifyListeners();
  }

  void updateBillingCountry(Country country) {
    _selectedBillingCountry = country;
    _billingCountryError = null;
    _selectedBillingProvince = null;
   // _billingProvinceError = null;
    cityInputController.clear();
    _cityInputError = null;
    notifyListeners();
  }

  void updateBillingProvince(Province province) {
    _selectedBillingProvince = province;
 //   _billingProvinceError = null;
    cityInputController.clear();
    _cityInputError = null;
    notifyListeners();
  }

  // Email Input & Error

  String? _emailInputError;

  String? get emailInputError => _emailInputError;

  void onEmailInputChanged(String text) {
    _notifyEmailInputError(null);
  }

  void _notifyEmailInputError(String? error) {
    _emailInputError = error;
    notifyListeners();
  }

  // Phone Number Input & Error

  String? _phoneNumberInputError;

  String? get phoneNumberInputError => _phoneNumberInputError;

  void onPhoneNumberInputChanged(String text) {
    _notifyPhoneNumberInputError(null);
  }

  void _notifyPhoneNumberInputError(String? error) {
    _phoneNumberInputError = error;
    notifyListeners();
  }

  // Address Line 1 Input & Error

  String? _addressLine1InputError;

  String? get addressLine1InputError => _addressLine1InputError;

  void onAddressLine1InputChanged(String text) {
    _notifyAddressLine1InputError(null);
  }

  void _notifyAddressLine1InputError(String? error) {
    _addressLine1InputError = error;
    notifyListeners();
  }

  // City Input & Error

  String? _cityInputError;

  String? get cityInputError => _cityInputError;

  void onCityInputChanged(String text) {
    _notifyLastNameInputError(null);
  }

  void _notifyCityInputError(String? error) {
    _cityInputError = error;
    notifyListeners();
  }

  // Postal Code Input & Error

  String? _postalCodeInputError;

  String? get postalCodeInputError => _postalCodeInputError;

  void onPostalCodeInputChanged(String text) {
    _notifyPostalCodeInputError(null);
  }

  void _notifyPostalCodeInputError(String? error) {
    _postalCodeInputError = error;
    notifyListeners();
  }

  /*
   * API: UPDATE BILLING DETAIL
   */

  async.CancelableOperation<Result>? _updateBillingDetailOp;

  Future<Result?> updateBillingDetail(BuildContext context) async {
    final localization = LocaleResources.of(context);

    _updateBillingDetailOp?.cancel();

    final firstNameInput = firstNameInputController.text.trim();
    final lastNameInput = lastNameInputController.text.trim();
    final emailInput = emailInputController.text.trim();
    final phoneNumberInput = phoneNumberInputController.text.trim();
    final addressLine1Input = addressLine1InputController.text.trim();
    final addressLine2Input = addressLine2InputController.text.trim();
    final cityInput = cityInputController.text.trim();
    final postalCodeInput = postalCodeInputController.text.trim();
    final companyNameInput = companyNameInputController.text.trim();
    final nationalIdInput = nationalIdInputController.text.trim();

    // Validate First Name
    String? firstNameInputError;
    if (firstNameInput.isEmpty) {
      firstNameInputError = localization.errorEnterFirstName;
    }
    _notifyFirstNameInputError(firstNameInputError);

    // Validate Last Name
    String? lastNameInputError;
    if (lastNameInput.isEmpty) {
      lastNameInputError = localization.errorEnterLastName;
    }
    _notifyLastNameInputError(lastNameInputError);

    // Validate Email
    String? emailInputError;
    final registeredEmail = profile?.email;
    if ((registeredEmail != null && registeredEmail.isNotEmpty) ||
        emailInput.isNotEmpty) {
      emailInputError = Validator.validateEmail(context, emailInput);
    }

    if (emailInput.isNotEmpty && emailInputError == null) {
      final isVerified = isEmailVerified(context);
      if (isVerified != true) {
        emailInputError = localization.errorVerifyEmail;
      }
    }

    _notifyEmailInputError(emailInputError);

    // Validate PhoneNumber
    String? phoneNumberInputError;
    if (phoneNumberInput.isNotEmpty) {
      final country = selectedPhoneNumberCountry;
      if (country == null) {
        phoneNumberInputError = localization.errorSelectCountry;
      } else {
        phoneNumberInputError = Validator.validatePhoneNumber(context, phoneNumberInput);
      }

      /*if (phoneNumberInputError == null) {
        final isPhoneVerified = isPhoneNumberVerified(context);
        if (isPhoneVerified != true) {
          phoneNumberInputError = localization.errorVerifyPhoneNumber;
        }
      }*/
    }

   _notifyPhoneNumberInputError(phoneNumberInputError);

    // Validate Address Line 1
    String? addressLine1InputError;
    if (addressLine1Input.isEmpty) {
      addressLine1InputError = localization.errorAddressLine1CannotBeEmpty;
    }
    _notifyAddressLine1InputError(addressLine1InputError);

    // Validate Billing Country
    Country? billingCountry = selectedBillingCountry;
    _billingCountryError =
        (billingCountry == null) ? localization.errorSelectCountry : null;

    // Validate Billing Province
    Province? billingProvince = selectedBillingProvince;
  // _billingProvinceError = (billingProvince == null) ? localization.errorSelectProvince : null;

    // Validate Billing City
    String? cityInputError;
    if (cityInput.isEmpty) {
      cityInputError = localization.errorEnterBillingCity;
    }
   // _notifyCityInputError(cityInputError);

    // Validate Postal Code
    String? postalCodeInputError;
    if (postalCodeInput.isEmpty) {
      postalCodeInputError = localization.errorPostalCodeCannotBeEmpty;
    }
    _notifyPostalCodeInputError(postalCodeInputError);
    notifyListeners();

    if (firstNameInputError != null ||
        lastNameInputError != null ||
        emailInputError != null ||
        phoneNumberInputError != null ||
        addressLine1InputError != null ||
        _billingCountryError != null ||
       // _billingProvinceError != null ||
       // cityInputError != null ||
        postalCodeInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Create operation
    final request = SetBillingDetailRequest(
      addressLine1: addressLine1Input,
      addressLine2: addressLine2Input,
      city: cityInput ==""?null:cityInput,
      email: emailInput,
      companyName: companyNameInput,
      countryId: billingCountry!.id,
      firstName: firstNameInput,
      id: targetBillingDetail?.id,
      lastName: lastNameInput,
      postalCode: postalCodeInput,
      provinceId: billingProvince !=null? billingProvince.id:null,
      nationalId: nationalIdInput,
      phoneNumberCountyID: billingCountry.id,
      phoneNumber:phoneNumberInput ,
    );
    final updateBillingDetailOp = async.CancelableOperation.fromFuture(
        locator<KwotData>().accountRepository.setBillingDetail(request));
    _updateBillingDetailOp = updateBillingDetailOp;

    // Listen for result
    return await updateBillingDetailOp.value;
  }

  /*
   * API: EMAIL VERIFICATION
   */

  bool? isEmailVerified(BuildContext context) {
    final profile = this.profile;
    if (profile == null) return null;

    final emailInput = emailInputController.text.trim();

    /// Using email from successful local-verification result
    if (emailInput == _locallyVerifiedEmail) {
      return true;
    }

    /// Using email from profile (already verified if available)
    if (emailInput == profile.email) {
      return true;
    }

    final error = Validator.validateEmail(context, emailInput);
    if (error != null) {
      return null;
    }

    return false;
  }

  ProfileEmailOtpRequest? createEmailOtpRequest(BuildContext context) {
    final emailInput = emailInputController.text.trim();

    // Validate Email
    final emailInputError = Validator.validateEmail(context, emailInput);
    _notifyEmailInputError(emailInputError);

    if (emailInputError != null) {
      // Validation failed.
      return null;
    }

    _locallyVerifiedEmail = null;
    return ProfileEmailOtpRequest(email: emailInput);
  }

  void updateLocallyVerifiedEmail({
    required String? email,
  }) {
    _locallyVerifiedEmail = email;
    notifyListeners();
  }

  /*
   * API: PHONE NUMBER VERIFICATION
   */

  bool? isPhoneNumberVerified(BuildContext context) {
    final profile = this.profile;
    if (profile == null) return null;

    final phoneNumberInput = phoneNumberInputController.text.trim();
    final selectedCountry = selectedPhoneNumberCountry;

    /// Using phone-number from successful local-verification result
    if (selectedCountry?.isoCode == _locallyVerifiedCountry?.isoCode &&
        phoneNumberInput == _locallyVerifiedPhoneNumber) {
      return true;
    }

    /// Using phone-number from profile (already verified if available)
    if (selectedCountry?.isoCode == profile.country?.isoCode &&
        phoneNumberInput == profile.phoneNumber) {
      return true;
    }

    if (selectedCountry == null) {
      return null;
    }

    final error = Validator.validatePhoneNumber(context, phoneNumberInput);
    if (error != null) {
      return null;
    }

    return false;
  }

  ProfilePhoneOtpRequest? createPhoneOtpRequest(BuildContext context) {
    final localization = LocaleResources.of(context);

    final phoneNumberInput = phoneNumberInputController.text.trim();

    // Validate Phone Number
    String? phoneNumberInputError;
    final selectedCountry = selectedPhoneNumberCountry;
    if (selectedCountry == null) {
      phoneNumberInputError = localization.errorSelectCountry;
    } else {
      phoneNumberInputError =
          Validator.validatePhoneNumber(context, phoneNumberInput);
    }
    _notifyPhoneNumberInputError(phoneNumberInputError);

    if (phoneNumberInputError != null) {
      // Validation failed.
      return null;
    }

    _locallyVerifiedCountry = null;
    _locallyVerifiedPhoneNumber = null;

    return ProfilePhoneOtpRequest(
      country: selectedCountry!,
      phoneNumber: phoneNumberInput,
    );
  }

  void updateLocallyVerifiedPhoneNumber({
    required Country? country,
    required String? phoneNumber,
  }) {
    _locallyVerifiedCountry = country;
    _locallyVerifiedPhoneNumber = phoneNumber;
    notifyListeners();
  }
}
