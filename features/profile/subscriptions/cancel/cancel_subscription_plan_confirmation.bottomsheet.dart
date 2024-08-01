import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';

class CancelSubscriptionPlanConfirmationBottomSheet extends StatelessWidget {
  //=
  static Future<bool?> show(
    BuildContext context, {
    required String planEndDate,
     required  bool isFromArtist,
        required VoidCallback onTapCancel,
  }) {
    return showMaterialBottomSheet<bool?>(
      context,
      expand: false,
      builder: (_, __) {
        return CancelSubscriptionPlanConfirmationBottomSheet(
            planEndDate: planEndDate, isFromArtist: isFromArtist, onTapCancel: onTapCancel,);
      },
    );
  }

   CancelSubscriptionPlanConfirmationBottomSheet({
    Key? key,
    required this.planEndDate,
    required this.isFromArtist,
    required  this.onTapCancel,
  }) : super(key: key);

  final String planEndDate;
  final bool isFromArtist;
  VoidCallback onTapCancel;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    final promptSubtitle = localization
        .cancelSubscriptionPromptSubtitle(planEndDate);

    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundCancelSubscription,
      highlightedActionTitle:isFromArtist?localization.continueMyPlan: localization.continueListeningWithoutLimits,
      onNormalActionTap: onTapCancel,//() => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: localization.cancelSubscription,
      subtitle: promptSubtitle,
      title:isFromArtist?localization.areYouSureYouWantToCancelYourFanPlan: localization.cancelSubscriptionPromptTitle,
      useSmallHeight: true,
    );
  }
}
