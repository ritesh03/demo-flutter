import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/show/options/show_options.bottomsheet.dart';
import 'package:kwotmusic/features/show/options/show_options.model.dart';
import 'package:kwotmusic/features/show/show_actions.model.dart';
import 'package:kwotmusic/features/show/widget/show_detail_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'shows.model.dart';

class ShowsPage extends StatefulWidget {
  const ShowsPage({Key? key}) : super(key: key);

  @override
  State<ShowsPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends PageState<ShowsPage> {
  //=

  @override
  void initState() {
    super.initState();
    showsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                child: _buildAppBar(),
                preferredSize: Size.fromHeight(ComponentSize.large.h)),
            body: ItemListWidget<Show, ShowsModel>(
                columnItemSpacing: ComponentInset.normal.h,
                headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
                footerSlivers: [DashboardConfigAwareFooter.asSliver()],
                itemBuilder: (context, show, index) {
                  return ShowDetailListItem(
                    show: show,
                    onTap: (show) => _onShowTapped(show),
                    onReminderButtonTap: _onReminderButtonTapped,
                    onOptionsButtonTap: _onOptionsButtonTapped,
                  );
                })));
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

  /*
   * HEADER
   */

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
        child: Selector<ShowsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).showsPageTitle,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).showsSearchHint,
          onQueryChanged: showsModelOf(context).updateSearchQuery,
          onQueryCleared: showsModelOf(context).clearSearchQuery,
        ));
  }

  /*
   * BODY
   */

  ShowsModel showsModelOf(BuildContext context) {
    return context.read<ShowsModel>();
  }

  void _onShowTapped(Show show) {
    hideKeyboard(context);
    locator<FeedRouting>().showShowDetailPage(context, show: show);
  }

  void _onReminderButtonTapped(Show show) async {
    // Show loading dialog
    showBlockingProgressDialog(context);

    // Call API
    final result = await locator<ShowActionsModel>().setIsReminderEnabled(
      id: show.id,
      shouldEnable: !show.isReminderEnabled,
    );

    // Close loading dialog
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    final message = result.message;
    if (message != null && message.isNotEmpty) {
      showDefaultNotificationBar(NotificationBarInfo.success(message: message));
    }

    // Alternative handled using Event Bus
  }

  void _onOptionsButtonTapped(Show show) {
    final args = ShowOptionsArgs(show: show);
    ShowOptionsBottomSheet.show(context, args: args);
  }
}
