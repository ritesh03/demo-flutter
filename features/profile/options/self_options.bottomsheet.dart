import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/user/widget/user_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:share_plus/share_plus.dart';

class SelfOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required User user,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => SelfOptionsBottomSheet(user: user),
    );
  }

  const SelfOptionsBottomSheet({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<SelfOptionsBottomSheet> createState() => _SelfOptionsBottomSheetState();
}

class _SelfOptionsBottomSheetState extends State<SelfOptionsBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          UserCompactPreview(user: widget.user),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          BottomSheetTile(
              iconPath: Assets.iconFriends,
              text: LocaleResources.of(context).findFriends,
              onTap: _onFindFriendsButtonTapped),
          SizedBox(height: ComponentInset.small.h),
          BottomSheetTile(
              iconPath: Assets.iconShare,
              text: LocaleResources.of(context).shareProfile,
              onTap: _onShareProfileButtonTapped),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  void _onFindFriendsButtonTapped() {
    RootNavigation.popUntilRoot(context);
    DashboardNavigation.pushNamed(context, Routes.findFriends);
  }

  void _onShareProfileButtonTapped() {
    RootNavigation.popUntilRoot(context);
    Share.share(widget.user.shareableLink);
  }
}
