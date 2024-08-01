import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class TrackExistsInPlaylistBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(BuildContext context) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => const TrackExistsInPlaylistBottomSheet(),
    );
  }

  const TrackExistsInPlaylistBottomSheet({Key? key}) : super(key: key);

  @override
  State<TrackExistsInPlaylistBottomSheet> createState() =>
      _TrackExistsInPlaylistBottomSheetState();
}

class _TrackExistsInPlaylistBottomSheetState
    extends State<TrackExistsInPlaylistBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundDuplicate,
      highlightedActionTitle: localization.skip,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: localization.playlistAddSongAllowDuplicateButton,
      subtitle: "",
      title: localization.playlistAddSongExists,
    );
  }
}
