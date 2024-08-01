import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    Key? key,
    required this.error,
    required this.onTryAgain,
    this.padding,
    this.showErrorMessageOnNewLine = false,
  }) : super(key: key);

  final dynamic error;
  final VoidCallback onTryAgain;
  final EdgeInsets? padding;
  final bool showErrorMessageOnNewLine;

  @override
  Widget build(BuildContext context) {
    //=

    final String message;
    if (error is SocketException) {
      message = LocaleResources.of(context).errorNoConnection;
    } else if (error != null) {
      message = showErrorMessageOnNewLine ? '\n$error' : error.toString();
    } else {
      message = LocaleResources.of(context).errorUnknown;
    }

    return Container(
        alignment: Alignment.center,
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: ComponentInset.large.w),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(message,
                  style: TextStyles.body,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: ComponentInset.normal.h),
              Button(
                  type: ButtonType.text,
                  text: LocaleResources.of(context).tryAgainButton,
                  onPressed: onTryAgain),
            ]));
  }
}
