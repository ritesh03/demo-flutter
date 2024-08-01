import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart' ;
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/activity/widget/user_activity_list_item.widget.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'users_activities.model.dart';

class UsersActivitiesPage extends StatefulWidget {
  const UsersActivitiesPage({Key? key}) : super(key: key);

  @override
  State<UsersActivitiesPage> createState() => _UsersActivitiesPageState();
}

class _UsersActivitiesPageState extends PageState<UsersActivitiesPage> {
  //=
  UsersActivitiesModel get _activitiesModel =>
      context.read<UsersActivitiesModel>();

  @override
  void initState() {
    super.initState();
    _activitiesModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar()),
        body: ItemListWidget<UserActivity, UsersActivitiesModel>(
            columnItemSpacing: ComponentInset.normal.h,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
            headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
            footerSlivers: [DashboardConfigAwareFooter.asSliver()],
            itemBuilder: (context, activity, index) {
              return UserActivityListItem(
                activity: activity,
                onTap: () => _onUserActivityTapped(activity),
              );
            }),
      ),
    );
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
    ]);
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.small.h),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.h),
      _buildSearchBar(),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<UsersActivitiesModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ??
                      // TODO: Update when other activities are available
                      LocaleResources.of(context).usersActivitiesPageTitle,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).usersActivitiesSearchHint,
          onQueryChanged: _activitiesModel.updateSearchQuery,
          onQueryCleared: _activitiesModel.clearSearchQuery,
        ));
  }

  void _onUserActivityTapped(UserActivity activity) {
    hideKeyboard(context);

    /// TODO: open activity-related page with kind-type when there are multiple kinds
    locator<AudioPlaybackActionsModel>().playTrack(activity.track);
  }
}
