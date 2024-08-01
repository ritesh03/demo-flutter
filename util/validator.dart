import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class Validator {
  static bool isEmail(String input) => EmailUtils.isEmail(input);

  static bool isPhone(String input) =>
      RegExp(r'^[+]?[(]?\d{3}[)]?[-\s.]?\d{3}[-\s.]?\d{4,6}$').hasMatch(input);

  /// Validate email: not-empty & matches-pattern
  static String? validateEmail(BuildContext context, String input) {
    final localization = LocaleResources.of(context);

    if (input.trim().isEmpty) {
      return localization.errorEmailCannotBeEmpty;
    }

    if (input.contains(" ")) {
      return localization.errorEmailCannotHaveSpaces;
    }

    if (!Validator.isEmail(input)) {
      return localization.errorEmailIsInvalid;
    }

    return null;
  }

  /// Validate password: not-empty & matches-pattern
  static String? validatePassword(
    BuildContext context,
    String input, {
    bool checkExistenceOnly = false,
  }) {
    final localization = LocaleResources.of(context);

    if (input.isEmpty) {
      return localization.errorPasswordCannotBeEmpty;
    }

    if (checkExistenceOnly) {
      return null;
    }

    /// Valid if:
    /// contains digits: (?=.*?[0-9])
    /// contains [A-Z] alphabet: (?=.*?[A-Z])
    /// contains [a-z] alphabet: (?=.*?[a-z])
    /// contains special symbols or underscore: (?=.*?[^\w\s]|.*[_])
    /// has length between 8 to 64 characters: .{8,64}
    ///
    /// Source: https://stackoverflow.com/a/33292812
    final isValid =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?\d)(?=.*?[^\w\s]|.*_).{8,64}$')
            .hasMatch(input);
    if (!isValid) {
      return localization.errorPasswordValidation;
    }

    return null;
  }

  /// Validate phone number: not-empty, no-spaces & matches-pattern
  static String? validatePhoneNumber(BuildContext context, String input) {
    final localization = LocaleResources.of(context);

    if (input.isEmpty) {
      return localization.errorPhoneNumberCannotBeEmpty;
    }

    if (input.contains(" ")) {
      return localization.errorPhoneNumberCannotHaveSpaces;
    }

    if (!Validator.isPhone(input)) {
      return localization.errorPhoneNumberIsInvalid;
    }

    return null;
  }

  /// Validate email: not-empty & matches-pattern
  /// Validate phone number: not-empty, no-spaces & matches-pattern
  @Deprecated("No uses")
  static IdentityType? validateIdentity(
    BuildContext context,
    String input,
    Function(String error) onError,
  ) {
    final localization = LocaleResources.of(context);

    if (input.isEmpty) {
      onError(localization.errorEmailOrPhoneNumberCannotBeEmpty);
      return null;
    }

    if (input.contains(" ")) {
      onError(localization.errorEmailOrPhoneNumberCannotHaveSpaces);
      return null;
    }

    if (input.contains("@")) {
      if (!Validator.isEmail(input)) {
        onError(localization.errorEmailIsInvalid);
        return null;
      }

      return IdentityType.email;
    }

    // either a phone-number or nothing
    String possiblePhoneNumberStr = input
        .replaceAll("-", "")
        .replaceAll("_", "")
        .replaceAll("+", "")
        .replaceAll("(", "")
        .replaceAll(")", "");
    final possiblePhoneNumber = int.tryParse(possiblePhoneNumberStr);
    if (possiblePhoneNumber != null) {
      // might be a phone-number
      if (!Validator.isPhone(possiblePhoneNumberStr)) {
        onError(localization.errorPhoneNumberIsInvalid);
        return null;
      }

      return IdentityType.phoneNumber;
    }

    // nothing acceptable
    onError(localization.errorEmailOrPhoneNumberIsInvalid);
    return null;
  }
}
