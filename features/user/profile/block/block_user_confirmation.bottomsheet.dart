import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/promptdialogsheet/prompt_dialog_sheet.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class BlockUserConfirmationBottomSheet extends StatefulWidget {
  //=
  static Future<bool?> show(
    BuildContext context, {
    required User user,
  }) {
    return showMaterialBottomSheet<bool>(
      context,
      expand: false,
      builder: (_, __) => BlockUserConfirmationBottomSheet(user: user),
    );
  }

  const BlockUserConfirmationBottomSheet({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<BlockUserConfirmationBottomSheet> createState() =>
      _BlockUserConfirmationBottomSheetState();
}

class _BlockUserConfirmationBottomSheetState
    extends State<BlockUserConfirmationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    final isBlocked = widget.user.isBlocked;

    final userName = widget.user.name;

    final title = isBlocked
        ? localization.unblockUserNameFormat(userName)
        : localization.blockUserNameFormat(userName);

    final subtitle = isBlocked
        ? localization.unblockUserConfirmationSubtitleFormat(userName)
        : localization.blockUserConfirmationSubtitleFormat(userName);

    final positiveActionTitle =
        isBlocked ? localization.unblockUser : localization.blockUser;

    return PromptDialogSheet(
      backgroundAssetPath: Assets.backgroundBlock,
      highlightedActionTitle: localization.cancel,
      onNormalActionTap: () => RootNavigation.pop(context, true),
      onHighlightedActionTap: () => RootNavigation.pop(context, false),
      normalActionTitle: positiveActionTitle,
      subtitle: subtitle,
      title: title,
    );
  }
}
