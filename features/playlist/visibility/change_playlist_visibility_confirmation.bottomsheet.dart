import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class ChangePlaylistVisibilityConfirmationBottomSheet extends StatelessWidget {
  //=
  static Future show(
    BuildContext context, {
    required bool makingPublic,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) {
        return ChangePlaylistVisibilityConfirmationBottomSheet(
          makingPublic: makingPublic,
        );
      },
    );
  }

  const ChangePlaylistVisibilityConfirmationBottomSheet({
    Key? key,
    required this.makingPublic,
  }) : super(key: key);

  final bool makingPublic;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return PromptDialogSheet(
      backgroundAssetPath: makingPublic
          ? Assets.backgroundMakePlaylistPublic
          : Assets.backgroundMakePlaylistPrivate,
      highlightedActionTitle: makingPublic
          ? localization.makePlaylistPublic
          : localization.makePlaylistPrivate,
      onNormalActionTap: () => RootNavigation.pop(context, false),
      onHighlightedActionTap: () => RootNavigation.pop(context, true),
      normalActionTitle: makingPublic
          ? localization.keepPlaylistPrivate
          : localization.keepPlaylistPublic,
      subtitle: makingPublic
          ? localization.makePlaylistPublicPromptSubtitle
          : localization.makePlaylistPrivatePromptSubtitle,
      title: makingPublic
          ? localization.makePlaylistPublicPromptTitle
          : localization.makePlaylistPrivatePromptTitle,
      useSmallHeight: true,
    );
  }
}
