

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/models/user/user.dart';
import 'package:provider/provider.dart';

import '../../components/kit/assets.dart';
import '../../components/kit/component_inset.dart';
import '../../components/kit/component_size.dart';
import '../../components/kit/textstyles.dart';
import '../../components/kit/theme/dynamic_theme.dart';
import '../../components/widgets/blocking_progress.dialog.dart';
import '../../components/widgets/button.dart';
import '../../components/widgets/list/item_list.widget.dart';
import '../../components/widgets/marquee/simple_marquee.dart';
import '../../components/widgets/notificationbar/notification_bar.dart';
import '../../components/widgets/sliverheader/basic_sliver_header_delegate.dart';
import '../../components/widgets/textfield/search/searchbar.widget.dart';
import '../../l10n/localizations.dart';
import '../../navigation/dashboard_navigation.dart';
import '../../router/routes.dart';
import '../../util/util.dart';
import '../dashboard/dashboard_config.dart';
import '../user/profile/user_profile.model.dart';
import '../user/user_actions.model.dart';
import '../user/widget/user_list_item.widget.dart';
import 'fans_model.dart';

class FansPageView extends StatefulWidget {
  final String artistId;
  final String artistName;
   FansPageView({Key? key,required this.artistId,required this.artistName}) : super(key: key);

  @override
  State<FansPageView> createState() => _FansPageViewState();
}

class _FansPageViewState extends State<FansPageView> {
  FansModel get fansModel => context.read<FansModel>();

  @override
  void initState() {
    fansModel.artistId = widget.artistId;
    fansModel.artistName = widget.artistName;
    fansModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
            body: ItemListWidget<User, FansModel>(
                columnItemSpacing: ComponentInset.normal.h,
                padding:
                EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                headerSlivers: [
                  _buildSliverAppBar(context),
                  SliverToBoxAdapter(child: _buildSearchBar(context)),
                ],
                footerSlivers: [DashboardConfigAwareFooter.asSliver()],
                itemBuilder: (context, user, index) {
                  return UserListItem(
                    user: user,
                    onTap: () =>_onUserTapped(user),
                    onFollowTap: () =>_onUserFollowTapped(user),
                  );
                })));
  }

  SliverPersistentHeader _buildSliverAppBar(BuildContext context) {
    final toolbarHeight = ComponentSize.large.h;
    final expandedHeight = toolbarHeight * 2;
    return SliverPersistentHeader(
        pinned: true,
        delegate: BasicSliverHeaderDelegate(
          context,
          toolbarHeight: toolbarHeight,
          expandedHeight: expandedHeight,
          topBar: Row(children: [
            AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).neutral20(),
                assetPath: Assets.iconArrowLeft,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: () => DashboardNavigation.pop(context)),
          ]),
          horizontalTitlePadding: ComponentInset.normal.w,
          title: _buildTitle(context),
        ));
  }

  Widget _buildTitle(BuildContext context) {
    return Selector<FansModel, String?>(
        selector: (_, model) => model.artistName,
        builder: (_, userName, __) {
          final title = (userName != null && userName.isNotEmpty)
              ? LocaleResources.of(context).fansOfUserFormat(userName)
              : LocaleResources.of(context).fans;
          return SimpleMarquee(
              text: title,
              textStyle: TextStyles.boldHeading2.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).search,
          onQueryChanged: fansModel.updateSearchQuery,
          onQueryCleared: fansModel.clearSearchQuery,
        ));
  }
  
  void _onUserTapped(User user) {
    hideKeyboard(context);
    Navigator.pushNamed(context, Routes.userProfile,
        arguments: UserProfileArgs(
          id: user.id,
          name: user.name,
          thumbnail: user.thumbnail,
        ));
  }

  void _onUserFollowTapped(User user) async {
    hideKeyboard(context);

    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<UserActionsModel>().setIsFollowed(
      id: user.id,
      shouldFollow: !user.isFollowed,
    );

    // Close loading dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // Alternative handled using Event Bus
  }
  
  
}
