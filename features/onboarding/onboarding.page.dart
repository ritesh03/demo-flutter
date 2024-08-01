import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indexed_page_indicator.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'onboarding.model.dart';
import 'widgets/onboarding_feature.widget.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends PageState<OnboardingPage>
    with TickerProviderStateMixin<OnboardingPage> {
  //=

  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //=

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(72.h),
          child: _buildAppBar(),
        ),
        body: Stack(children: [
          _Carousel(controller: _controller),
          Positioned(
              top: OnboardingFeature.totalHeightFactor,
              width: 1.sw,
              child: _CarouselIndicators(onPageSelected: _onPageSelected))
        ]),
        bottomNavigationBar: Button(
            height: ComponentSize.large.h,
            margin: EdgeInsets.all(ComponentInset.normal.r),
            text: LocaleResources.of(context).signInButton,
            onPressed: _onSignInButtonPressed),
      ),
    );
  }

  Widget _buildAppBar() {
    final logoSize = ComponentSize.normal.r;
    return Row(children: [
      /// LOGO
      Container(
          height: logoSize,
          margin: EdgeInsets.all(ComponentInset.normal.r),
          child: Image.asset(
            Assets.graphicLogoRoundedSmall,
            width: logoSize,
            height: logoSize,
          )),
      const Spacer(),

      /// REGISTER BUTTON
      Button(
          height: ComponentSize.normal.h,
          text: LocaleResources.of(context).registerButton,
          margin: EdgeInsets.all(ComponentInset.normal.r),
          type: ButtonType.text,
          onPressed: _onRegisterButtonPressed),
    ]);
  }

  /*
   * ACTIONS
   */

  void _onPageSelected(index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  void _onSignInButtonPressed() {
    DashboardNavigation.pushNamed(context, Routes.authSignIn);
  }

  void _onRegisterButtonPressed() {
    DashboardNavigation.pushNamed(context, Routes.authSignUp);
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: PageView(
          controller: controller,

          // "allowImplicitScrolling" kind of preloads next page.
          allowImplicitScrolling: true,
          children: [
            OnboardingFeature(
                title: LocaleResources.of(context).onboardingMusicTitle,
                subtitle: LocaleResources.of(context).onboardingMusicSubtitle,
                assetPath: Assets.graphicOnboardingMusic),
            OnboardingFeature(
                title: LocaleResources.of(context).onboardingFriendsTitle,
                subtitle: LocaleResources.of(context).onboardingFriendsSubtitle,
                assetPath: Assets.graphicOnboardingFriends),
            OnboardingFeature(
                title: LocaleResources.of(context).onboardingRadioTitle,
                subtitle: LocaleResources.of(context).onboardingRadioSubtitle,
                assetPath: Assets.graphicOnboardingRadio),
          ],
          onPageChanged: (index) {
            context.read<OnboardingModel>().updatePageIndex(index);
          }),
    );
  }
}

class _CarouselIndicators extends StatelessWidget {
  const _CarouselIndicators({
    Key? key,
    required this.onPageSelected,
  }) : super(key: key);

  final Function(int) onPageSelected;

  @override
  Widget build(BuildContext context) {
    return Selector<OnboardingModel, int>(
        selector: (_, model) => model.currentPageIndex,
        builder: (_, selectedPageIndex, __) {
          final height = ComponentSize.smallest.h;
          return Container(
              height: height,
              alignment: Alignment.center,
              child: IndexedPageIndicator(
                  count: 3,
                  size: height * 3 / 4,
                  selectedIndex: selectedPageIndex,
                  onPressed: onPageSelected));
        });
  }
}
