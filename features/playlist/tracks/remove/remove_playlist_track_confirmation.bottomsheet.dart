import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class RemovePlaylistTrackConfirmationBottomSheet extends StatelessWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => const RemovePlaylistTrackConfirmationBottomSheet(),
    );
  }

  const RemovePlaylistTrackConfirmationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundRemovePlaylistTrack,
      highlightedActionTitle: LocaleResources.of(context).cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: LocaleResources.of(context).playlistRemoveSong,
      subtitle: LocaleResources.of(context).playlistRemoveSongPromptSubtitle,
      title: LocaleResources.of(context).playlistRemoveSongPromptTitle,
      useSmallHeight: true,
    );
  }
}
