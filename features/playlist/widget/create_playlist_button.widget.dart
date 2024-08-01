import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class CreatePlaylistButton extends StatelessWidget {
  const CreatePlaylistButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconTextButton(
        color: DynamicTheme.get(context).secondary100(),
        height: ComponentSize.small.r,
        iconPath: Assets.iconAddMedium,
        iconSize: ComponentSize.smaller.r,
        iconTextSpacing: ComponentInset.small.w,
        text: LocaleResources.of(context).createPlaylist,
        textStyle: TextStyles.boldHeading5,
        onPressed: onTap);
  }
}
