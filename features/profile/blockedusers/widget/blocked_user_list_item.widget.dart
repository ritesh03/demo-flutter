import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class BlockedUserListItem extends StatelessWidget {
  const BlockedUserListItem({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onBlockStatusButtonTap,
  }) : super(key: key);

  final User user;
  final VoidCallback onTap;
  final VoidCallback onBlockStatusButtonTap;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: ComponentInset.normal.w),
      _buildPhoto(context),
      SizedBox(width: ComponentInset.small.w),
      Expanded(child: _buildTitle(context)),
      SizedBox(width: ComponentInset.small.w),
      _buildBlockStatusButton(context),
      SizedBox(width: ComponentInset.normal.w),
    ]);
  }

  Widget _buildPhoto(BuildContext context) {
    final size = ComponentSize.large.r;
    return ScaleTap(
      onPressed: onTap,
      child: Photo.user(
        user.thumbnail,
        options: PhotoOptions(
          width: size,
          height: size,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      child: Text(
        user.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()),
      ),
    );
  }

  Widget _buildBlockStatusButton(BuildContext context) {
    return Button(
      onPressed: onBlockStatusButtonTap,
      overriddenForegroundColor: user.isBlocked
          ? DynamicTheme.get(context).secondary100()
          : DynamicTheme.get(context).neutral10(),
      text: user.isBlocked
          ? LocaleResources.of(context).unblock
          : LocaleResources.of(context).block,
      type: ButtonType.text,
    );
  }
}
