import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:in_app_review/in_app_review.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/navigation/root_navigation.dart';

class FeedbackRatingPromptBottomSheet extends StatefulWidget {
  //=
  static Future show(BuildContext context, FeedbackSmiley smiley) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => FeedbackRatingPromptBottomSheet(smiley: smiley),
    );
  }

  const FeedbackRatingPromptBottomSheet({
    Key? key,
    required this.smiley,
  }) : super(key: key);

  final FeedbackSmiley smiley;

  @override
  State<FeedbackRatingPromptBottomSheet> createState() =>
      _FeedbackRatingPromptBottomSheetState();
}

class _FeedbackRatingPromptBottomSheetState
    extends State<FeedbackRatingPromptBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    final title = localization.feedbackRatingPromptDialogTitle;

    final String subtitle;
    final String highlightedActionTitle;
    final String normalActionTitle;
    if (widget.smiley == FeedbackSmiley.happy) {
      if (Platform.isAndroid) {
        subtitle = localization.feedbackGoodRatingDialogSubtitleAndroid;
      } else if (Platform.isIOS) {
        subtitle = localization.feedbackGoodRatingDialogSubtitleIOS;
      } else {
        throw Exception("Unknonwn platform");
      }

      highlightedActionTitle =
          localization.feedbackGoodRatingDialogPositiveAction;
      normalActionTitle = localization.feedbackGoodRatingDialogNegativeAction;
    } else {
      subtitle = localization.feedbackBadRatingDialogSubtitle;

      highlightedActionTitle =
          localization.feedbackBadRatingDialogPositiveAction;
      normalActionTitle = "";
    }

    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundFeedback,
      highlightedActionTitle: highlightedActionTitle,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () {
        if (widget.smiley == FeedbackSmiley.happy) {
          /// Open Store app
          InAppReview.instance.openStoreListing(
            appStoreId: LaunchConfig.app.androidApplicationId,
          );
        }
        RootNavigation.pop(context, false);
      },
      normalActionTitle: normalActionTitle,
      subtitle: subtitle,
      title: title,
    );
  }
}
