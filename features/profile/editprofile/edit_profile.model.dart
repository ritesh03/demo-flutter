import 'dart:io';

import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:image_picker/image_picker.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/photochooserselectionsheet/photo_chooser_selection_sheet.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class EditProfileModel with ChangeNotifier {
  //=
  async.CancelableOperation<Result<Profile>>? _profileOp;
  Result<Profile>? profileResult;

  TextEditingController firstNameEditingController = TextEditingController();
  TextEditingController lastNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();

  String? _locallyVerifiedEmail;
  Country? _locallyVerifiedCountry;
  String? _locallyVerifiedPhoneNumber;

  final ImagePicker _picker = ImagePicker();

  void init() {
    fetchProfile();
  }

  @override
  void dispose() {
    _profileOp?.cancel();
    _profileOp = null;

    _updateProfileOp?.cancel();
    _updateProfileOp = null;
    super.dispose();
  }

  bool get canSave {
    final profileResult = this.profileResult;
    return profileResult != null && profileResult.isSuccess();
  }

  Profile? get profile => profileResult?.peek();

  String? get profilePhotoPath =>
      _selectedProfilePhotoFile?.path ?? profile?.profilePhoto;

  Country? get selectedCountry => _selectedCountry ?? profile?.country;

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
        firstNameEditingController.text = profile.firstName;
        lastNameEditingController.text = profile.lastName;
        emailEditingController.text = profile.email ?? "";
        phoneEditingController.text = profile.phoneNumber ?? "";
      }
      profileResult = result;
    } catch (error) {
      profileResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      // Cancel current operation (if any)
      _profileOp?.cancel();

      // Create Request
      _profileOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchProfile());

      // Wait for result
      final result = await _profileOp?.value;
      if (result != null && result.isSuccess()) {
        final oldProfile = profileResult?.data();
        final newProfile = result.data();

        if (oldProfile != null) {
          if (oldProfile.profilePhoto != newProfile.profilePhoto) {
            _selectedProfilePhotoFile = null;
          }

          if (oldProfile.firstName != newProfile.firstName) {
            firstNameEditingController.text = newProfile.firstName;
          }

          if (oldProfile.lastName != newProfile.lastName) {
            lastNameEditingController.text = newProfile.lastName;
          }

          if (oldProfile.email != newProfile.email) {
            emailEditingController.text = newProfile.email ?? "";
          }

          if (oldProfile.country != newProfile.country) {
            _selectedCountry = newProfile.country;
          }

          if (oldProfile.phoneNumber != newProfile.phoneNumber) {
            phoneEditingController.text = newProfile.phoneNumber ?? "";
          }
        }
        profileResult = result;
      }
    } catch (error) {
      // intentionally ignored.
    }
    notifyListeners();
  }

  /*
   * First Name Input
   */

  String? _firstNameInputError;

  String? get firstNameInputError => _firstNameInputError;

  void onFirstNameInputChanged(String text) {
    _notifyFirstNameInputError(null);
  }

  void _notifyFirstNameInputError(String? error) {
    _firstNameInputError = error;
    notifyListeners();
  }

  /*
   * Last Name Input
   */

  String? _lastNameInputError;

  String? get lastNameInputError => _lastNameInputError;

  void onLastNameInputChanged(String text) {
    _notifyLastNameInputError(null);
  }

  void _notifyLastNameInputError(String? error) {
    _lastNameInputError = error;
    notifyListeners();
  }

  /*
   * Email Input
   */

  String? _emailInputError;

  String? get emailInputError => _emailInputError;

  void onEmailInputChanged(String text) {
    _notifyEmailInputError(null);
  }

  void _notifyEmailInputError(String? error) {
    _emailInputError = error;
    notifyListeners();
  }

  /*
   * Country
   */

  Country? _selectedCountry;

  void updateCountry(Country country) {
    _selectedCountry = country;
    _phoneNumberInputError = null;
    notifyListeners();
  }

  /*
   * Phone Number Input
   */

  String? _phoneNumberInputError;

  String? get phoneNumberInputError => _phoneNumberInputError;

  void onPhoneNumberInputChanged(String text) {
    _notifyPhoneNumberInputError(null);
  }

  void _notifyPhoneNumberInputError(String? error) {
    _phoneNumberInputError = error;
    notifyListeners();
  }

  /*
   * PHOTO
   */

  File? _selectedProfilePhotoFile;

  void pickPhoto(PhotoChooser chooser) async {
    final ImageSource imageSource;
    switch (chooser) {
      case PhotoChooser.camera:
        imageSource = ImageSource.camera;
        break;
      case PhotoChooser.gallery:
        imageSource = ImageSource.gallery;
        break;
    }

    final pickedFile = await _picker.pickImage(
      source: imageSource,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (pickedFile == null) {
      return;
    }

    _selectedProfilePhotoFile = File(pickedFile.path);
    notifyListeners();
  }

  /*
   * API: UPDATE PROFILE
   */

  async.CancelableOperation? _updateProfileOp;

  Future<Result<Profile>?> updateProfile(BuildContext context) async {
    final profile = this.profile;
    if (profile == null) {
      return null;
    }

    final localization = LocaleResources.of(context);

    _updateProfileOp?.cancel();

    final firstNameInput = firstNameEditingController.text.trim();
    final lastNameInput = lastNameEditingController.text.trim();
    final emailInput = emailEditingController.text.trim().toLowerCase();
    final phoneNumberInput = phoneEditingController.text.trim();

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
    final registeredEmail = profile.email;
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
    final registeredPhoneNumber = profile.phoneNumber;
    if ((registeredPhoneNumber != null && registeredPhoneNumber.isNotEmpty) ||
        phoneNumberInput.isNotEmpty) {
      final country = selectedCountry;
      if (country == null) {
        phoneNumberInputError = localization.errorSelectCountry;
      } else {
        phoneNumberInputError =
            Validator.validatePhoneNumber(context, phoneNumberInput);
      }
    }

    if (phoneNumberInput.isNotEmpty && phoneNumberInputError == null) {
      final isVerified = isPhoneNumberVerified(context);
      if (isVerified != true) {
        phoneNumberInputError = localization.errorVerifyPhoneNumber;
      }
    }

    _notifyPhoneNumberInputError(phoneNumberInputError);

    if (firstNameInputError != null ||
        lastNameInputError != null ||
        emailInputError != null ||
        phoneNumberInputError != null) {
      // One of the validations failed.
      return null;
    }

    final profilePhotoFile = _selectedProfilePhotoFile;
    if (profilePhotoFile != null && !profilePhotoFile.existsSync()) {
      return Result.error(localization.errorSelectedPhotoDoesNotExist);
    }

    // Create operation
    final updatedFirstName =
        (profile.firstName == firstNameInput || firstNameInput.isEmpty)
            ? null
            : firstNameInput;

    final updatedLastName =
        (profile.lastName == lastNameInput || lastNameInput.isEmpty)
            ? null
            : lastNameInput;

    final updatedPhotoFile =
        (profilePhotoFile == null) ? null : profilePhotoFile;

    if (updatedFirstName == null &&
        updatedLastName == null &&
        updatedPhotoFile == null) {
      await refreshProfile();
      return profileResult;
    }

    final request = UpdateProfileRequest(
      firstName: updatedFirstName,
      lastName: updatedLastName,
      photoFile: updatedPhotoFile,
    );

    final updateProfileOp =
        async.CancelableOperation<Result<Profile>>.fromFuture(
            locator<KwotData>().accountRepository.updateProfile(request));
    _updateProfileOp = updateProfileOp;

    // Listen for result
    return await updateProfileOp.value;
  }

  /*
   * API: EMAIL VERIFICATION
   */

  bool? isEmailVerified(BuildContext context) {
    final profile = this.profile;
    if (profile == null) return null;

    final emailInput = emailEditingController.text.trim();
    if (emailInput.isEmpty) {
      return null;
    }

    if (emailInput == _locallyVerifiedEmail) {
      return true;
    }

    if (emailInput == profile.email) {
      return profile.emailVerified;
    }

    final error = Validator.validateEmail(context, emailInput);
    if (error != null) {
      return null;
    }

    return false;
  }

  ProfileEmailOtpRequest? createEmailOtpRequest(BuildContext context) {
    final emailInput = emailEditingController.text.trim().toLowerCase();

    // Validate Email
    String? emailInputError;
    final registeredEmail = profile?.email;
    if (registeredEmail != null || emailInput.isNotEmpty) {
      emailInputError = Validator.validateEmail(context, emailInput);
    }
    _notifyEmailInputError(emailInputError);

    if (emailInputError != null) {
      // Validation failed.
      return null;
    }

    _locallyVerifiedEmail = null;

    // Create operation
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

    final phoneNumberInput = phoneEditingController.text.trim();
    final selectedCountry = this.selectedCountry;

    if (selectedCountry?.isoCode == _locallyVerifiedCountry?.isoCode &&
        phoneNumberInput == _locallyVerifiedPhoneNumber) {
      return true;
    }

    // TODO: Test this scenario properly
    final profileCountryIsoCode = profile.country?.isoCode;
    if (profileCountryIsoCode != null &&
        (selectedCountry == null ||
            (selectedCountry.isoCode == profileCountryIsoCode)) &&
        profile.phoneNumber == phoneNumberInput) {
      return profile.phoneNumberVerified;
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

    final phoneNumberInput = phoneEditingController.text.trim();

    // Validate Phone Number
    String? phoneNumberInputError;
    final selectedCountry = this.selectedCountry;
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

    // Create operation
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
