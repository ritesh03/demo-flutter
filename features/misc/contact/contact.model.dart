import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/validator.dart';

class ContactModel with ChangeNotifier {
  //=

  async.CancelableOperation<Result<List<ContactReason>>>? _contactReasonsOp;
  Result<List<ContactReason>>? contactReasonsResult;

  TextEditingController emailInputController = TextEditingController();
  TextEditingController descriptionInputController = TextEditingController();
  ContactReason? selectedContactReason;

  String? registrationEmail;

  ContactModel() {
    final email = locator<KwotData>().storageRepository.getEmail();
    if (email != null) {
      registrationEmail = email;
      emailInputController.text = email;
    }
  }

  void init() {
    fetchContactReasons();
  }

  @override
  void dispose() {
    _contactReasonsOp?.cancel();
    _contactReasonsOp = null;

    _contentRequestOp?.cancel();
    _contentRequestOp = null;
    super.dispose();
  }

  bool get canSubmitRequest {
    return contactReasonsResult != null &&
        contactReasonsResult!.isSuccess() &&
        contactReasonsResult!.data().isNotEmpty;
  }

  Future<void> fetchContactReasons() async {
    try {
      // Cancel current operation (if any)
      _contactReasonsOp?.cancel();

      if (contactReasonsResult != null) {
        contactReasonsResult = null;
        notifyListeners();
      }

      // Create Request
      _contactReasonsOp = async.CancelableOperation.fromFuture(
          locator<KwotData>().accountRepository.fetchContactReasons());

      // Wait for result
      contactReasonsResult = await _contactReasonsOp?.value;
    } catch (error) {
      contactReasonsResult = Result.error("Error: $error");
    }
    notifyListeners();
  }

  /*
   * Contact Reason Input
   */

  String? _contactReasonInputError;

  String? get contactReasonInputError => _contactReasonInputError;

  void onContactReasonInputChanged(String text) {
    _notifyContactReasonInputError(null);
  }

  void _notifyContactReasonInputError(String? error) {
    _contactReasonInputError = error;
    notifyListeners();
  }

  void updateSelectedContactReason(ContactReason contactReason) {
    selectedContactReason = contactReason;
    _notifyContactReasonInputError(null);
  }

  /*
   * Email Input
   */

  String? _emailInputError;

  String? get emailInputError => _emailInputError;

  bool get canEditEmail => (registrationEmail == null);

  void onEmailInputChanged(String text) {
    _notifyEmailInputError(null);
  }

  void _notifyEmailInputError(String? error) {
    _emailInputError = error;
    notifyListeners();
  }

  /*
   * Description Input
   */

  String? _descriptionInputError;

  String? get descriptionInputError => _descriptionInputError;

  void onDescriptionInputChanged(String text) {
    _notifyDescriptionInputError(null);
  }

  void _notifyDescriptionInputError(String? error) {
    _descriptionInputError = error;
    notifyListeners();
  }

  /*
   * API: CONTACT REQUEST
   */

  async.CancelableOperation<Result>? _contentRequestOp;

  Future<Result?> submitContactRequest(BuildContext context) async {
    final localization = LocaleResources.of(context);

    _contentRequestOp?.cancel();

    // Validate contact-reason
    final contactReason = selectedContactReason;
    String? contactReasonInputError;
    if (contactReason == null) {
      contactReasonInputError = localization.errorContactReasonNotSelected;
    }
    _notifyContactReasonInputError(contactReasonInputError);

    // Validate Email
    final emailInput = emailInputController.text.trim();
    String? emailInputError = Validator.validateEmail(context, emailInput);
    _notifyEmailInputError(emailInputError);

    // Validate Description
    final descriptionInput = descriptionInputController.text.trim();
    String? descriptionInputError;
    if (descriptionInput.isEmpty) {
      descriptionInputError = localization.errorEnterContactRequestDescription;
    } else if (descriptionInput.length < 20) {
      descriptionInputError = localization.errorContactDescriptionTooShort;
    }
    _notifyDescriptionInputError(descriptionInputError);

    if (contactReasonInputError != null ||
        emailInputError != null ||
        descriptionInputError != null) {
      // One of the validations failed.
      return null;
    }

    // Create operation
    final request = ContactRequest(
      reasonId: contactReason!.id,
      email: emailInput,
      description: descriptionInput,
    );

    final contactRequestOp = async.CancelableOperation<Result>.fromFuture(
        locator<KwotData>().accountRepository.submitContactRequest(request));
    _contentRequestOp = contactRequestOp;

    // Listen for result
    return await contactRequestOp.value;
  }
}
