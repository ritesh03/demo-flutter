import 'dart:math';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/core.dart';

/*
 * TODO: Update blocking-progress when anim-resource is available
 *
 * Current Colors:
 *  background: black().withOpacity(0.8)
 *  card-background: secondary20()
 *  card-foreground: secondary120()
 */

void showBlockingProgressDialog(
  BuildContext context, {
  bool barrierDismissible = false,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: DynamicTheme.get(context).black().withOpacity(0.8),
    useRootNavigator: true,
    pageBuilder: (_, __, ___) =>
        BlockingProgressDialog(isDismissible: barrierDismissible),
  );
}

void hideBlockingProgressDialog(BuildContext context) {
  RootNavigation.pop(context);
}

class BlockingProgressDialog extends AlertDialog {
  //=

  const BlockingProgressDialog({
    Key? key,
    this.isDismissible = false,
  }) : super(key: key);

  final bool isDismissible;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _buildInfiniteProgressBar(context),
      contentPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildInfiniteProgressBar(BuildContext context) {
    final backgroundColor = DynamicTheme.get(context).surface();
    final foregroundColor = DynamicTheme.get(context).onSurface();
    final progressContainerSize = min(0.3.sw, 108.w);

    return WillPopScope(
        onWillPop: () async => isDismissible,
        child: Center(
            child: Card(
                elevation: 2,
                color: backgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ComponentRadius.larger.h)),
                child: Container(
                  width: progressContainerSize,
                  height: progressContainerSize,
                  padding: EdgeInsets.all(progressContainerSize / 3),
                  child: CircularProgressIndicator(color: foregroundColor),
                ))));
  }
}
