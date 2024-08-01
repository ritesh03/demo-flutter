import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/accountrecovery/request/request_account_recovery.page.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'change_password.model.dart';

class ChangePasswordPageArgs {
  ChangePasswordPageArgs({
    required this.sourceRouteName,
  });

  final String sourceRouteName;
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends PageState<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar(),
          ),
          body: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ComponentInset.normal.h),
                      _buildTitle(),
                      SizedBox(height: ComponentInset.small.h),
                      _buildSubtitle(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildCurrentPasswordInput(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildForgotPasswordButton(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildNewPasswordInput(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildRepeatPasswordInput(),
                      const DashboardConfigAwareFooter(),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      _buildSaveButton(),
      SizedBox(width: ComponentInset.normal.w)
    ]);
  }

  Widget _buildSaveButton() {
    return Selector<ChangePasswordModel, bool>(
        selector: (_, model) => model.canSave,
        builder: (_, canSave, __) {
          return Button(
              text: LocaleResources.of(context).save,
              type: ButtonType.text,
              enabled: canSave,
              height: ComponentSize.smaller.h,
              onPressed: _onSaveButtonTapped);
        });
  }

  Widget _buildTitle() {
    return Container(
      height: ComponentSize.small.h,
      alignment: Alignment.centerLeft,
      child: Text(LocaleResources.of(context).changePasswordPageTitle,
          style: TextStyles.boldHeading2),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(LocaleResources.of(context).changePasswordPageSubtitle,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral20())),
    );
  }

  Widget _buildCurrentPasswordInput() {
    return Selector<ChangePasswordModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.currentPasswordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: modelOf(context).currentPasswordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).currentPasswordHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).currentPasswordLabel,
            onChanged: (text) =>
                modelOf(context).onNewPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    modelOf(context).togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  Widget _buildForgotPasswordButton() {
    return Button(
        height: ComponentSize.smaller.h,
        text: LocaleResources.of(context).forgotPasswordButton,
        type: ButtonType.text,
        onPressed: _onForgotPasswordButtonPressed);
  }

  Widget _buildNewPasswordInput() {
    return Selector<ChangePasswordModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.newPasswordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: modelOf(context).newPasswordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).newPasswordHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).newPasswordLabel,
            onChanged: (text) =>
                modelOf(context).onNewPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    modelOf(context).togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  Widget _buildRepeatPasswordInput() {
    return Selector<ChangePasswordModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.repeatPasswordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: modelOf(context).repeatPasswordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).repeatPasswordHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).repeatPasswordLabel,
            onChanged: (text) =>
                modelOf(context).onRepeatPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    modelOf(context).togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  ChangePasswordModel modelOf(BuildContext context) {
    return context.read<ChangePasswordModel>();
  }

  /*
   * Actions
   */

  void _onForgotPasswordButtonPressed() {
    final currentPageArgs = obtainRouteArgs<ChangePasswordPageArgs?>(context);
    final sourceRouteName = currentPageArgs?.sourceRouteName;

    final nextPageArgs = (sourceRouteName != null)
        ? RequestAccountRecoveryPageArgs(sourceRouteName: sourceRouteName)
        : null;

    DashboardNavigation.pushReplacementNamed(
      context,
      Routes.requestAccountRecovery,
      arguments: nextPageArgs,
    );
  }

  void _onSaveButtonTapped() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    modelOf(context).changePassword(context).then((result) {
      // hide progress dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      // Password updated, notify
      showDefaultNotificationBar(
          NotificationBarInfo.success(message: result.message));

      final currentPageArgs = obtainRouteArgs<ChangePasswordPageArgs?>(context);
      final sourceRouteName = currentPageArgs?.sourceRouteName;
      if (sourceRouteName != null) {
        DashboardNavigation.popUntil(context, (route) {
          return route.settings.name == sourceRouteName;
        });
      } else {
        DashboardNavigation.pop(context);
      }
    });
  }
}
