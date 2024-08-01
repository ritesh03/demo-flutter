import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/toggle_switch.dart';
import 'package:kwotmusic/l10n/localizations.dart';

import '../../profile/subscriptions/subscription_enforcement.dart';
import 'playlist_visibility_support.widget.dart';

class PlaylistVisibilityTile extends PlaylistVisibilityStatefulWidget {
  const PlaylistVisibilityTile({
    Key? key,
    this.margin = EdgeInsets.zero,
    required Playlist playlist,
  }) : super(key: key, playlist: playlist);

  final EdgeInsets margin;

  @override
  State<PlaylistVisibilityTile> createState() => _PlaylistVisibilityTileState();
}

class _PlaylistVisibilityTileState
    extends PlaylistVisibilityState<PlaylistVisibilityTile> {
  //=

  @override
  Widget build(BuildContext context) {
    final isPublic = isPlaylistPublic;
    final itemHeight = ComponentSize.normal.r;
    final foregroundColor = DynamicTheme.get(context).neutral10();
    final selectedForegroundColor = DynamicTheme.get(context).white();
    final localization = LocaleResources.of(context);
    return Container(
        height: itemHeight,
        margin: widget.margin,
        padding: EdgeInsets.symmetric(vertical: ComponentInset.small.r),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AppIconTextButton(
              color: !isPublic ? selectedForegroundColor : foregroundColor,
              height: itemHeight,
              iconPath: Assets.iconLock,
              iconSize: ComponentSize.smaller.r,
              iconTextSpacing: ComponentInset.smaller.w,
              text: localization.private,
              textStyle: !isPublic ? TextStyles.boldBody : TextStyles.body,
              baseWidthTextStyle: TextStyles.boldBody,
              onPressed: () => onUpdateVisibilityTap(makePublic: false)),
          const Spacer(),
          ToggleSwitch(
              width: ComponentSize.smaller.r * 2,
              height: ComponentSize.smaller.r,
              checked: isPublic,
              onChanged: (checked) {
                final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
                  context,
                  feature: "see-what-friends-are-listening-to", text:  LocaleResources.of(context).yourSubscriptionDoesNotAllowMakePlayListPublic,
                );
                if (!fulfilled) return;
                onToggleVisibilityTap();
              }),
          const Spacer(),
          AppIconTextButton(
              color: isPublic ? selectedForegroundColor : foregroundColor,
              height: itemHeight,
              iconPath: Assets.iconPublic,
              iconSize: ComponentSize.smaller.r,
              iconTextSpacing: ComponentInset.smaller.w,
              text: localization.public,
              textStyle: isPublic ? TextStyles.boldBody : TextStyles.body,
              baseWidthTextStyle: TextStyles.boldBody,
              onPressed: () => onUpdateVisibilityTap(makePublic: true)),
        ]));
  }
}
