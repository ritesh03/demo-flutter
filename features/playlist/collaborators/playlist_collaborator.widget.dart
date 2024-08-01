import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PlaylistCollaboratorListItem extends StatelessWidget {
  const PlaylistCollaboratorListItem({
    Key? key,
    required this.collaborator,
    required this.onToggleModerationAccess,
    required this.onToggleViewAccess,
  }) : super(key: key);

  final PlaylistCollaborator collaborator;
  final VoidCallback onToggleModerationAccess;
  final VoidCallback onToggleViewAccess;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    final bgColor = DynamicTheme.get(context).secondary20();
    final hasViewAccess = collaborator.canView;

    return Container(
      decoration: BoxDecoration(
        color: hasViewAccess ? bgColor : bgColor.withOpacity(0),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
      padding: EdgeInsets.all(ComponentInset.small.r),
      child: Column(children: [
        Row(children: [
          _ProfilePhoto(
            photoUrl: collaborator.photo,
            size: ComponentSize.small.r,
          ),
          SizedBox(width: ComponentInset.small.r),
          Expanded(child: _ProfileTitle(text: collaborator.name)),
          SizedBox(width: ComponentInset.normal.r),
          _SelectionButton(
            text: hasViewAccess ? localization.unselect : localization.select,
            onTap: onToggleViewAccess,
          ),
          SizedBox(width: ComponentInset.small.r),
        ]),
        AnimatedSize(
          duration: Duration(milliseconds: hasViewAccess ? 190 : 230),
          child: Container(
              alignment: Alignment.bottomCenter,
              height: hasViewAccess ? ComponentSize.large.r : 0,
              child: _ModerationSwitch(
                checked: collaborator.canEditItems,
                onChanged: (_) => onToggleModerationAccess(),
                title: localization.playlistAllowAddRemoveSongsPrompt,
              )),
        ),
      ]),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    Key? key,
    required this.photoUrl,
    required this.size,
  }) : super(key: key);

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Photo.user(
      photoUrl,
      options: PhotoOptions(
        width: size,
        height: size,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }
}

class _SelectionButton extends StatelessWidget {
  const _SelectionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
      height: ComponentSize.small.r,
      text: text,
      type: ButtonType.text,
      onPressed: onTap,
    );
  }
}

class _ModerationSwitch extends StatelessWidget {
  const _ModerationSwitch({
    Key? key,
    required this.checked,
    required this.title,
    required this.onChanged,
  }) : super(key: key);

  final bool checked;
  final String title;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ComponentInset.smaller.r),
      child: BottomSheetSwitchTile(
          checked: checked,
          height: ComponentSize.smaller.r,
          onChanged: onChanged,
          text: title),
    );
  }
}
