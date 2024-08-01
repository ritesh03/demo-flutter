import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/auth/session/session.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'set_password.model.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({Key? key}) : super(key: key);

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends PageState<SetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(ComponentSize.large.h),
              child: _buildAppBar()),
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
                      SizedBox(height: ComponentInset.medium.h),
                      _buildNewPasswordInput(),
                      SizedBox(height: ComponentInset.normal.h),
                      _buildRepeatPasswordInput(),
                      SizedBox(height: ComponentInset.medium.h),
                      _buildSubmitButton(),
                      SizedBox(height: ComponentInset.small.h),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _buildAppBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      AppIconButton(
        width: ComponentSize.normal.r,
        height: ComponentSize.normal.r,
        assetColor: DynamicTheme.get(context).neutral20(),
        assetPath: Assets.iconCrossBold,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: _onBackPressed,
      ),
    ]);
  }

  Widget _buildTitle() {
    return Container(
      height: 80.h,
      alignment: Alignment.centerLeft,
      child: Text(LocaleResources.of(context).setPasswordPageTitle,
          style: TextStyles.boldHeading1),
    );
  }

  Widget _buildNewPasswordInput() {
    return Selector<SetPasswordModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.newPasswordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller:
                context.read<SetPasswordModel>().newPasswordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).newPasswordHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).newPasswordLabel,
            onChanged: (text) => context
                .read<SetPasswordModel>()
                .onNewPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    context.read<SetPasswordModel>().togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  Widget _buildRepeatPasswordInput() {
    return Selector<SetPasswordModel, Tuple2<String?, bool>>(
        selector: (_, model) => Tuple2(
              model.repeatPasswordInputError,
              model.isPasswordVisible,
            ),
        builder: (_, tuple, __) {
          final passwordInputError = tuple.item1;
          final isPasswordVisible = tuple.item2;

          final height = ComponentSize.large.h;

          return TextInputField(
            controller: context
                .read<SetPasswordModel>()
                .repeatPasswordEditingController,
            errorText: passwordInputError,
            hintText: LocaleResources.of(context).repeatPasswordHint,
            height: height,
            isPassword: !isPasswordVisible,
            labelText: LocaleResources.of(context).repeatPasswordLabel,
            onChanged: (text) => context
                .read<SetPasswordModel>()
                .onRepeatPasswordInputChanged(text),
            suffixes: [
              PasswordVisibilityToggleSuffix(
                  hasError: (passwordInputError != null),
                  isPasswordVisible: isPasswordVisible,
                  size: height,
                  onPressed: () {
                    context.read<SetPasswordModel>().togglePasswordVisibility();
                  }),
            ],
          );
        });
  }

  Widget _buildSubmitButton() {
    return Button(
        width: 1.sw,
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).setPasswordButtonText,
        type: ButtonType.primary,
        onPressed: _onSubmitButtonPressed);
  }

  /*
   * Actions
   */

  void _onBackPressed() => DashboardNavigation.pop(context);

  void _onSubmitButtonPressed() {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    showBlockingProgressDialog(context);

    context.read<SetPasswordModel>().setPassword(context).then((result) {
      // hide progress dialog
      hideBlockingProgressDialog(context);

      if (result == null) return;

      if (!result.isSuccess()) {
        showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()),
        );
        return;
      }

      // Password updated
      showDefaultNotificationBar(
          NotificationBarInfo.success(message: result.message));

      final sourceRouteName = context.read<SetPasswordModel>().sourceRouteName;
      if (sourceRouteName != null && locator<SessionModel>().hasSession) {
        // Signed In, pop until source route
        DashboardNavigation.popUntil(context, (route) {
          return route.settings.name == sourceRouteName;
        });
        return;
      }

      // Not Signed In, continue to Sign In
      DashboardNavigation.pushNamedAndRemoveUntil(
          context, Routes.authSignIn, (route) => false);
    });
  }
}
