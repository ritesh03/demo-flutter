import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/app_config.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/toggle_chip.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'onboarding_genre_selection.model.dart';

class OnboardingGenreSelectionPage extends StatefulWidget {
  const OnboardingGenreSelectionPage({Key? key}) : super(key: key);

  @override
  State<OnboardingGenreSelectionPage> createState() =>
      _OnboardingGenreSelectionPageState();
}

class _OnboardingGenreSelectionPageState
    extends PageState<OnboardingGenreSelectionPage> {
  //=
  OnboardingGenreSelectionModel get _genreSelectionModel =>
      context.read<OnboardingGenreSelectionModel>();

  @override
  void initState() {
    super.initState();
    _genreSelectionModel.fetchMusicGenres();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: ComponentInset.normal.h),
          _buildTitle(),
          SizedBox(height: ComponentInset.smaller.r),
          _buildSubtitle(),
          Expanded(child: _buildGenreChips()),
          _buildFooter(),
        ]),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Text(
            LocaleResources.of(context).onboardingGenreSelectionPageTitle,
            style: TextStyles.boldHeading1));
  }

  Widget _buildSubtitle() {
    final subtitle = LocaleResources.of(context)
        .onboardingGenreSelectionPageSubtitle(
            AppConfig.minimumOnboardingGenres);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Text(subtitle,
          style: TextStyles.body
              .copyWith(color: DynamicTheme.get(context).neutral20())),
    );
  }

  Widget _buildGenreChips() {
    return Selector<OnboardingGenreSelectionModel, Result<List<ChipItem>>?>(
        selector: (_, model) => model.genreChipsResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return Center(
                child: ErrorIndicator(
                    error: result.error(),
                    onTryAgain: _genreSelectionModel.fetchMusicGenres));
          }

          final items = result.data();
          if (items.isEmpty) {
            return const Center(child: EmptyIndicator());
          }

          return ToggleChipMasonryGrid(
            crossAxisCount: 7,
            crossAxisSpacing: ComponentInset.normal.r,
            mainAxisSpacing: ComponentInset.normal.r,
            items: items,
            onChipPressed: (item) {
              _genreSelectionModel.onGenreSelectionToggled(item.identifier);
            },
            padding: EdgeInsets.all(ComponentInset.normal.r),
          );
        });
  }

  Widget _buildFooter() {
    return Container(
        alignment: Alignment.centerLeft,
        height: 80.h,
        padding: EdgeInsets.only(right: ComponentInset.normal.w),
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).background(),
            boxShadow: BoxShadows.footerButtonsOnBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ComponentRadius.normal.h),
              topRight: Radius.circular(ComponentRadius.normal.h),
            )),
        child: Row(children: [
          Expanded(flex: 2, child: _buildSkipButton()),
          Expanded(flex: 3, child: _buildContinueButton())
        ]));
  }

  Widget _buildContinueButton() {
    return Selector<OnboardingGenreSelectionModel, int>(
        selector: (_, model) => model.selectedGenreCount,
        builder: (context, selectedGenreCount, __) {
          return Button(
              height: ComponentSize.large.h,
              text: LocaleResources.of(context).continueButton,
              type: ButtonType.primary,
              visuallyDisabled:
                  selectedGenreCount < AppConfig.minimumOnboardingGenres,
              onPressed: _onContinueButtonTapped);
        });
  }

  Widget _buildSkipButton() {
    return Button(
        height: ComponentSize.large.h,
        text: LocaleResources.of(context).skip,
        type: ButtonType.text,
        onPressed: _onSkipButtonTapped);
  }

  /*
   * ACTIONS
   */

  void _onContinueButtonTapped() async {
    final selectedGenreCount = _genreSelectionModel.selectedGenreCount;
    const minimumGenreCount = AppConfig.minimumOnboardingGenres;
    if (selectedGenreCount < minimumGenreCount) {
      showDefaultNotificationBar(
        NotificationBarInfo.error(
            message: LocaleResources.of(context)
                .errorSelectMinimumOnboardingGenres(minimumGenreCount)),
      );
      return;
    }

    showBlockingProgressDialog(context);
    final result = await _genreSelectionModel.updateFavoriteMusicGenres();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    DashboardNavigation.pushNamedAndRemoveUntil(
        context, Routes.dashboard, (_) => false);
  }

  void _onSkipButtonTapped() {
    DashboardNavigation.pushNamedAndRemoveUntil(
      context,
      Routes.dashboard,
      (_) => false,
    );
  }
}
