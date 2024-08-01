import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class DeleteAccountConfirmationBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(BuildContext context) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => const DeleteAccountConfirmationBottomSheet(),
    );
  }

  const DeleteAccountConfirmationBottomSheet({Key? key}) : super(key: key);

  @override
  State<DeleteAccountConfirmationBottomSheet> createState() =>
      _DeleteAccountConfirmationBottomSheetState();
}

class _DeleteAccountConfirmationBottomSheetState
    extends State<DeleteAccountConfirmationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundDelete,
      highlightedActionTitle: LocaleResources.of(context).cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: LocaleResources.of(context).deleteAccount,
      subtitle: LocaleResources.of(context).deleteAccountDialogSubtitle,
      title: LocaleResources.of(context).deleteAccountDialogTitle,
    );
  }
}
