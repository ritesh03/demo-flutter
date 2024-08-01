import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/user/profile/block/block_user_confirmation.bottomsheet.dart';
import 'package:kwotmusic/features/user/user_actions.model.dart';
import 'package:kwotmusic/features/user/widget/user_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'user_options.model.dart';

class UserOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required User user,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) {
        return ChangeNotifierProvider(
          create: (_) => UserOptionsModel(user: user),
          child: const UserOptionsBottomSheet(),
        );
      },
    );
  }

  const UserOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<UserOptionsBottomSheet> createState() => _UserOptionsBottomSheetState();
}

class _UserOptionsBottomSheetState extends State<UserOptionsBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final tileMargin = EdgeInsets.only(top: ComponentInset.small.h);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          _buildHeader(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          _buildBlockOption(tileMargin),
          _buildShareOption(tileMargin),
          _buildReportOption(tileMargin),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildHeader() {
    return Selector<UserOptionsModel, User>(
        selector: (_, model) => model.user,
        builder: (_, user, __) {
          return UserCompactPreview(user: user);
        });
  }

  Widget _buildBlockOption(EdgeInsets tileMargin) {
    return Selector<UserOptionsModel, bool>(
        selector: (_, model) => model.isBlocked,
        builder: (_, blocked, __) {
          return BottomSheetTile(
              iconPath: blocked ? Assets.iconUnlock : Assets.iconLock,
              margin: tileMargin,
              text: blocked
                  ? LocaleResources.of(context).unblock
                  : LocaleResources.of(context).block,
              onTap: _onBlockButtonTapped);
        });
  }

  Widget _buildShareOption(EdgeInsets tileMargin) {
    return Selector<UserOptionsModel, bool>(
        selector: (_, model) => model.canShowShareOption,
        builder: (_, canShow, __) {
          if (!canShow) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconShare,
              margin: tileMargin,
              text: LocaleResources.of(context).share,
              onTap: _onShareButtonTapped);
        });
  }

  Widget _buildReportOption(EdgeInsets tileMargin) {
    return Selector<UserOptionsModel, bool>(
        selector: (_, model) => model.canShowReportOption,
        builder: (_, canShow, __) {
          if (!canShow) return Container();
          return BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: _onReportButtonTapped);
        });
  }

  UserOptionsModel modelOf(BuildContext context) {
    return context.read<UserOptionsModel>();
  }

  ArtistActionsModel artistActionsModel() {
    return locator<ArtistActionsModel>();
  }

  void _onBlockButtonTapped() async {
    final user = modelOf(context).user;

    bool? shouldContinue =
        await BlockUserConfirmationBottomSheet.show(context, user: user);
    if (shouldContinue == null || !shouldContinue) {
      return;
    }

    // Show progress
    if (!mounted) return;
    showBlockingProgressDialog(context);

    final Result<User> result;
    if (user.isBlocked) {
      result = await locator<UserActionsModel>().unblockUser(id: user.id);
    } else {
      result = await locator<UserActionsModel>().blockUser(id: user.id);
    }

    // Hide progress
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));
  }

  void _onShareButtonTapped() async {
    final user = modelOf(context).user;
    final shareableLink = user.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onReportButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final user = modelOf(context).user;
    final args = ReportContentArgs(content: ReportableContent.fromUser(user));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
