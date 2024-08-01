import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class DeleteBillingDetailsConfirmationBottomSheet extends StatefulWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => const DeleteBillingDetailsConfirmationBottomSheet(),
    );
  }

  const DeleteBillingDetailsConfirmationBottomSheet({Key? key})
      : super(key: key);

  @override
  State<DeleteBillingDetailsConfirmationBottomSheet> createState() =>
      _DeleteBillingDetailsConfirmationBottomSheetState();
}

class _DeleteBillingDetailsConfirmationBottomSheetState
    extends State<DeleteBillingDetailsConfirmationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundDelete,
      highlightedActionTitle: LocaleResources.of(context).cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: LocaleResources.of(context).deleteBillingDetails,
      subtitle: LocaleResources.of(context).deleteBillingDetailsDialogSubtitle,
      title: LocaleResources.of(context).deleteBillingDetailsDialogTitle,
    );
  }
}
