import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/photo/blurred_cover_photo.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/features/dashboard/account/account_home.model.dart';
import 'package:kwotmusic/features/dashboard/dashboard.model.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/profile/notifications/widget/notifications_icon_button.widget.dart';
import 'package:kwotmusic/features/profile/widget/account_option_horizontal_item.widget.dart';
import 'package:kwotmusic/features/user/profile/user_profile.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/prefs.dart';
import 'package:kwotmusic/util/util_url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../util/util.dart';
import '../../profile/deleteaccount/delete_account_confirmation.bottomsheet.dart';

class AccountHomePage extends StatefulWidget {
  const AccountHomePage({Key? key}) : super(key: key);

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends PageState<AccountHomePage>
    with AutomaticKeepAliveClientMixin<AccountHomePage> {
  //=

  @override
  void initState() {
    super.initState();
    accountModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Selector<AccountHomeModel, Result<Profile>?>(
        selector: (_, model) => model.profileResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return ErrorIndicator(
              error: result.error(),
              onTryAgain: () => accountModelOf(context).fetchProfile(),
            );
          }

          return _buildContent();
        });
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildContent() {
    return RefreshIndicator(
        color: DynamicTheme.get(context).secondary100(),
        backgroundColor: DynamicTheme.get(context).black(),
        onRefresh: () =>
            Future.sync(() => accountModelOf(context).fetchProfile()),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(children: <Widget>[
              _buildProfileCoverPhoto(),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileTopBar(),
                    SizedBox(height: ComponentInset.normal.h),
                    _buildProfileInfo(),
                    _buildPaymentHistoryOption(),
                    _buildSubscriptionDetailsOption(),
                    _buildBillingDetailsOption(),
                    _buildMyWallet(),
                    _buildHelpOption(),
                    _buildBlockedUsersOption(),
                    _buildRateAppButton(),
                    _buildTermsButton(),
                    _buildLogoutButton(),
                   // _buildDeleteAccountButton(),
                    const DashboardConfigAwareFooter()
                  ])
            ])));
  }

  Widget _buildProfileTopBar() {
    return Row(children: [
      const Spacer(),
      NotificationsIconButton(
        iconPadding: EdgeInsets.all(ComponentInset.small.r),
        onTap: _onNotificationsIconTapped,
        size: ComponentSize.large.r,
      ),
      //   AppIconButton(
      //       width: ComponentSize.large.r,
      //       height: ComponentSize.large.r,
      //       assetColor: DynamicTheme.get(context).white(),
      //       assetPath: Assets.iconSettings,
      //       padding: EdgeInsets.all(ComponentInset.small.r),
      //       onPressed: _onSettingsIconTapped),
    ]);
  }

  Widget _buildProfileCoverPhoto() {
    return Selector<AccountHomeModel, String?>(
        selector: (_, model) => model.coverPhotoPath,
        builder: (_, photoPath, __) {
          return BlurredCoverPhoto(
              photoPath: photoPath,
              photoKind: PhotoKind.profileCover,
              height: 192.h);
        });
  }

  Widget _buildProfileInfo() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Row(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            _buildProfilePhoto(),
            _buildEditProfilePhotoButton(),
          ]),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildProfileName(), _buildPublicProfileButton()]))
        ]));
  }

  Widget _buildProfilePhoto() {
    return Selector<AccountHomeModel, String?>(
        selector: (_, model) => model.profilePhotoPath,
        builder: (_, photoPath, __) {
          return Photo.user(
            photoPath,
            options: PhotoOptions(
              width: 104.r,
              height: 104.r,
              shape: BoxShape.circle,
            ),
          );
        });
  }

  Widget _buildEditProfilePhotoButton() {
    return ScaleTap(
        onPressed: _onEditProfilePhotoButtonTapped,
        child: Container(
            alignment: Alignment.center,
            width: ComponentSize.small.r,
            height: ComponentSize.small.r,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DynamicTheme.get(context).white()),
            padding: EdgeInsets.all(ComponentInset.smaller.r),
            child: SvgPicture.asset(
              Assets.iconEdit,
              color: DynamicTheme.get(context).black(),
            )));
  }

  Widget _buildProfileName() {
    return SizedBox(
        height: ComponentSize.small.h,
        child: Selector<AccountHomeModel, String?>(
            selector: (_, model) => model.name,
            builder: (_, name, __) {
              return Text(name ?? "",
                  style: TextStyles.boldHeading2,
                  overflow: TextOverflow.ellipsis);
            }));
  }

  Widget _buildPublicProfileButton() {
    return Button(
      onPressed: _onPublicProfileButtonTapped,
      text: LocaleResources.of(context).seePublicProfile,
      type: ButtonType.text,
      height: ComponentSize.smaller.h,
    );
  }

  Widget _buildPaymentHistoryOption() {
    return optionOf(
      iconPath: Assets.iconPayment,
      text: LocaleResources.of(context).paymentHistory,
      onTap: _onPaymentHistoryOptionTapped,
    );
  }

  Widget _buildSubscriptionDetailsOption() {
    return optionOf(
      iconPath: Assets.iconSubscription,
      text: LocaleResources.of(context).mySubscription,
      onTap: _onSubscriptionDetailsOptionTapped,
    );
  }

  Widget _buildBillingDetailsOption() {
    return optionOf(
      iconPath: Assets.iconBilling,
      text: LocaleResources.of(context).billingDetails,
      onTap: _onBillingDetailsOptionTapped,
    );
  }

  Widget _buildHelpOption() {
    return optionOf(
      iconPath: Assets.iconHelp,
      text: LocaleResources.of(context).help,
      onTap: _onHelpOptionTapped,
    );
  }

  Widget _buildMyWallet() {
    return optionOf(
      iconPath: Assets.myWalletIcon,
      text: LocaleResources.of(context).myWallet,
      onTap: _onMyWalletTapped,
    );
  }

  Widget _buildBlockedUsersOption() {
    return optionOf(
      iconPath: Assets.iconLock,
      text: LocaleResources.of(context).blockedUsers,
      onTap: _onBlockedUsersOptionTapped,
    );
  }

  Widget _buildRateAppButton() {
    return Button(
      margin: EdgeInsets.only(
        top: ComponentInset.normal.r,
        left: ComponentInset.normal.r,
        right: ComponentInset.normal.r,
      ),
      text: LocaleResources.of(context).rateTheApp,
      height: ComponentSize.large.h,
      type: ButtonType.primary,
      width: MediaQuery.of(context).size.width,
      onPressed: _onRateAppButtonTapped,
    );
  }

  Widget _buildTermsButton() {
    return Button(
      margin: EdgeInsets.only(
        top: ComponentInset.medium.r,
        left: ComponentInset.normal.r,
        right: ComponentInset.normal.r,
      ),
      text: LocaleResources.of(context).privacyPolicyAndTermsOfUse,
      height: ComponentSize.smaller.h,
      type: ButtonType.text,
      onPressed: _onTermsButtonTapped,
    );
  }

  Widget _buildLogoutButton() {
    final margin = ComponentInset.normal.r;
    return AppIconTextButton(
        color: DynamicTheme.get(context).neutral10(),
        height: ComponentSize.smaller.h,
        iconPath: Assets.iconLogout,
        iconTextSpacing: ComponentInset.smaller.w,
        margin: EdgeInsets.only(top: margin, left: margin, right: margin),
        text: LocaleResources.of(context).logOut,
        textStyle: TextStyles.boldHeading5,
        onPressed: _onLogoutButtonTapped);
  }


  Widget _buildDeleteAccountButton() {
    return AppIconTextButton(
        color: DynamicTheme.get(context).neutral10(),
        height: ComponentSize.smaller.h,
        iconPath: Assets.iconDelete,
        iconTextSpacing: ComponentInset.smaller.w,
        text: LocaleResources.of(context).deleteAccount,
        textStyle: TextStyles.boldHeading5,
        onPressed: _onDeleteAccountButtonTapped);
  }
  DashboardModel dashboardModelOf(BuildContext context) {
    return context.read<DashboardModel>();
  }

  AccountHomeModel accountModelOf(BuildContext context) {
    return context.read<AccountHomeModel>();
  }

  /*
   * ACTIONS
   */

  AccountOptionHorizontalItem optionOf({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    return AccountOptionHorizontalItem(
        height: ComponentSize.large.h,
        margin: EdgeInsets.only(
          top: ComponentInset.normal.r,
          left: ComponentInset.normal.r,
          right: ComponentInset.normal.r,
        ),
        iconPath: iconPath,
        text: text,
        onTap: onTap);
  }

  void _onNotificationsIconTapped() {
    DashboardNavigation.pushNamed(context, Routes.notifications);
  }

  void _onSettingsIconTapped() {
    DashboardNavigation.pushNamed(context, Routes.settings);
  }

  void _onEditProfilePhotoButtonTapped() async {
    final updatedProfile =
        await DashboardNavigation.pushNamed(context, Routes.editProfile);
    if (!mounted) return;
    if (updatedProfile != null && updatedProfile is Profile) {
      accountModelOf(context).updateProfile(updatedProfile);
    }
  }

  void _onPublicProfileButtonTapped() {
    final profile = accountModelOf(context).profile;
    if (profile == null) return;

    DashboardNavigation.pushNamed(context, Routes.userProfile,
        arguments: UserProfileArgs(
          id: profile.id,
          name: profile.name,
          thumbnail: profile.profilePhoto,
        ));
  }

  void _onPaymentHistoryOptionTapped() {
    DashboardNavigation.pushNamed(context, Routes.paymentHistory);
  }

  void _onSubscriptionDetailsOptionTapped() {
    DashboardNavigation.pushNamed(context, Routes.manageSubscription);
  }

  void _onBillingDetailsOptionTapped() {
    DashboardNavigation.pushNamed(context, Routes.billingDetails);
  }

  void _onHelpOptionTapped() {
    DashboardNavigation.pushNamed(context, Routes.help);
  }
  void _onMyWalletTapped() {
    DashboardNavigation.pushNamed(context, Routes.myWalletPage);
  }

  void _onBlockedUsersOptionTapped() {

    DashboardNavigation.pushNamed(context, Routes.blockedUsers);
  }

  void _onRateAppButtonTapped() {
    DashboardNavigation.pushNamed(context, Routes.feedback);
  }

  void _onTermsButtonTapped() {
    UrlLauncherUtil.openTermsConditionsPage(context);
  }

  void _onLogoutButtonTapped() {

    SharedPref.prefs!.clear();
    // show processing dialog
    showBlockingProgressDialog(context);
    // Stop playback
    locator<AudioPlaybackActionsModel>().stopPlayback();

    // logout
    locator<SessionModel>().logout().then((result) {
      // hide dialog
      if (!mounted) return;
      hideBlockingProgressDialog(context);

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
            NotificationBarInfo.error(message: result.error()));
        return;
      }

      // go to authentication page
      DashboardNavigation.pushNamedAndRemoveUntil(
          context, Routes.authSignIn, (route) => false);
    });
  }

  void _onDeleteAccountButtonTapped() async {
    hideKeyboard(context);

    bool? shouldDelete =
    await DeleteAccountConfirmationBottomSheet.show(context);
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    // show processing dialog
    if (!mounted) return;
    showBlockingProgressDialog(context);

    // stop playback
    locator<AudioPlaybackActionsModel>().stopPlayback();

    // delete account
    final result = await locator<SessionModel>().deleteAccount();

    // hide dialog
    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
        NotificationBarInfo.error(message: result.error()),
      );
      return;
    }

    showDefaultNotificationBar(
        NotificationBarInfo.success(message: result.message));

    // go to onboarding page
    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.onboarding, (route) => false);
  }


}
