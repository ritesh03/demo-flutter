import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class RemoveAllPlaylistCollaboratorsConfirmationBottomSheet
    extends StatelessWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) =>
          const RemoveAllPlaylistCollaboratorsConfirmationBottomSheet(),
    );
  }

  const RemoveAllPlaylistCollaboratorsConfirmationBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundRemoveAllCollaborators,
      highlightedActionTitle: localization.cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: localization.removeAll,
      subtitle: localization.removeAllCollaboratorsPromptSubtitle,
      title: localization.removeAllCollaboratorsPromptTitle,
    );
  }
}
