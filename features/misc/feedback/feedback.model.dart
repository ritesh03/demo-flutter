import 'package:async/async.dart' as async;
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/util/validator.dart';

class FeedbackModel with ChangeNotifier {
  //=

  FeedbackSmiley _feedbackSmiley = FeedbackSmiley.happy;
  TextEditingController emailInputController = TextEditingController();
  TextEditingController feedbackTextInputController = TextEditingController();

  String? registrationEmail;

  FeedbackSmiley get feedbackSmiley => _feedbackSmiley;

  FeedbackModel() {
    final email = locator<KwotData>().storageRepository.getEmail();
    if (email != null) {
      registrationEmail = email;
      emailInputController.text = email;
    }
  }

  @override
  void dispose() {
    _submitFeedbackOp?.cancel();
    _submitFeedbackOp = null;
    super.dispose();
  }

  /*
   * Feedback Smiley
   */

  void onFeedbackSmileyChanged(FeedbackSmiley smiley) {
    _feedbackSmiley = smiley;
    notifyListeners();
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
   * API: SUBMIT FEEDBACK
   */

  async.CancelableOperation<Result>? _submitFeedbackOp;

  Future<Result?> submitFeedback(BuildContext context) async {
    _submitFeedbackOp?.cancel();

    // Validate Email
    final emailInput = emailInputController.text.trim();
    String? emailInputError = Validator.validateEmail(context, emailInput);
    _notifyEmailInputError(emailInputError);

    final feedbackTextInput = feedbackTextInputController.text.trim();

    if (emailInputError != null) {
      return null;
    }

    // Create operation
    final request = SendFeedbackRequest(
      smiley: _feedbackSmiley,
      email: emailInput,
      text: feedbackTextInput,
    );

    final submitFeedbackOp = async.CancelableOperation<Result>.fromFuture(
        locator<KwotData>().accountRepository.sendFeedback(request));
    _submitFeedbackOp = submitFeedbackOp;

    // Listen for result
    return await submitFeedbackOp.value;
  }
}
