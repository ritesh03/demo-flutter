import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/navigation/root_navigation.dart';

class DeleteDownloadConfirmationBottomSheet extends StatelessWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => const DeleteDownloadConfirmationBottomSheet(),
    );
  }

  const DeleteDownloadConfirmationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PromptDialogSheet(
      useSmallHeight: true,
      backgroundAssetPath: Assets.backgroundDeleteDownload,
      highlightedActionTitle: LocaleResources.of(context).cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: LocaleResources.of(context).deleteDownload,
      subtitle: LocaleResources.of(context).deleteDownloadPromptSubtitle,
      title: LocaleResources.of(context).deleteDownloadPromptTitle,
    );
  }
}
