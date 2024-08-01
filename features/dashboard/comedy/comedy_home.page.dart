import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/feed/feed.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/dashboard/widget/titlebar/dashboard_title.widgets.dart';
import 'package:kwotmusic/features/search/search.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'comedy_home.model.dart';

class ComedyHomePage extends StatefulWidget {
  const ComedyHomePage({Key? key}) : super(key: key);

  @override
  State<ComedyHomePage> createState() => _ComedyHomePageState();
}

class _ComedyHomePageState extends PageState<ComedyHomePage>
    with AutomaticKeepAliveClientMixin<ComedyHomePage> {
  //=
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<ComedyHomeModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageTitleBarWrapper(
      barHeight: 48.r,
      title: DashboardPageTitle(
          text: LocaleResources.of(context).video,
          color: DynamicTheme.get(context).white(),
          onTap: _scrollController.animateToTop),
      actions: [
        DashboardPageTitleAction(
            asset: Assets.iconSearch,
            color: DynamicTheme.get(context).neutral20(),
            onTap: _onSearchBarTap),
      ],
      child: ItemListWidget<Feed, ComedyHomeModel>.optionalSeparator(
          controller: _scrollController,
          columnItemSpacing: ComponentInset.medium.r,
          headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
          footerSlivers: [DashboardConfigAwareFooter.asSliver()],
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, feed, index) {
            return FeedWidget(feed: feed, itemSpacing: ComponentInset.normal.r);
          },
          shouldShowListItemSeparator: (feed, index) {
            return !feed.isEmpty;
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildHeader() {
    return Container(
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTitle(), _buildSearchBar()]));
  }

  Widget _buildTitle() {
    return Container(
      height: ComponentSize.normal.h,
      margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
      child: Text(LocaleResources.of(context).video,
          style: TextStyles.boldHeading1.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }

  Widget _buildSearchBar() {
    return ScaleTap(
      scaleMinValue: 0.98,
      onPressed: _onSearchBarTap,
      child: AbsorbPointer(
          child: SearchBar(
              hintText: LocaleResources.of(context).searchVideos)),
    );
  }

  void _onSearchBarTap() {
    DashboardNavigation.pushNamed(context, Routes.search,
        arguments: SearchArgs(source: SearchSource.comedians));
  }
}
