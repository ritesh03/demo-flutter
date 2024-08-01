import 'package:flutter/services.dart';

class ValidationUtil {
  static final text = _TextValidationUtil();
}

class _TextValidationUtil {
  TextCapitalization get nameInputCapitalization => TextCapitalization.words;

  List<TextInputFormatter> get nameInputFormatters {
    return [
      LengthLimitingTextInputFormatter(48),
      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
    ];
  }

  TextCapitalization get playlistNameInputCapitalization =>
      TextCapitalization.words;

  List<TextInputFormatter> get playlistNameInputFormatters {
    return [
      LengthLimitingTextInputFormatter(48),
    ];
  }

  List<TextInputFormatter> get playlistDescriptionInputFormatters {
    return [
      LengthLimitingTextInputFormatter(320),
    ];
  }
}
