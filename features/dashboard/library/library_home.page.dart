import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/dashboard/widget/titlebar/dashboard_title.widgets.dart';
import 'package:kwotmusic/features/playlist/widget/create_playlist_button.widget.dart';
import 'package:kwotmusic/features/profile/subscriptions/subscription_enforcement.dart';
import 'package:kwotmusic/features/search/search.model.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/navigation/dashboard_navigation.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'library_home.model.dart';

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({Key? key}) : super(key: key);

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends PageState<LibraryHomePage>
    with AutomaticKeepAliveClientMixin<LibraryHomePage> {
  //=
  late ScrollController _scrollController;

  LibraryHomeModel get _libraryModel => context.read<LibraryHomeModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _libraryModel.init();

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageTitleBarWrapper(
      barHeight: 48.r,
      title: DashboardPageTitle(
          text: LocaleResources.of(context).tabLibrary,
          color: DynamicTheme.get(context).white(),
          onTap: _scrollController.animateToTop),
      actions: [
        DashboardPageTitleAction(
            asset: Assets.iconSearch,
            color: DynamicTheme.get(context).neutral20(),
            onTap: _onSearchBarTap),
      ],
      child: _ItemList(
        header: _PageHeader(
          onCreatePlaylistTap: _onCreatePlaylistTap,
          onDownloadsTap: _onDownloadsTap,
          onSearchTap: _onSearchBarTap,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _onCreatePlaylistTap() {
    hideKeyboard(context);
    DashboardNavigation.pushNamed(context, Routes.createOrEditPlaylist);
  }

  void _onDownloadsTap() {
    final fulfilled = SubscriptionEnforcement.fulfilSubscriptionRequirement(
      context,
      feature: "offline-download", text: LocaleResources.of(context).yourSubscriptionDoesNotAllowMessage,

    );
    if (!fulfilled) return;

    DashboardNavigation.pushNamed(context, Routes.downloads);
  }

  void _onSearchBarTap() {
    DashboardNavigation.pushNamed(context, Routes.search,
        arguments: SearchArgs(source: SearchSource.comedians));
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    Key? key,
    required this.onCreatePlaylistTap,
    required this.onDownloadsTap,
    required this.onSearchTap,
  }) : super(key: key);

  final VoidCallback onCreatePlaylistTap;
  final VoidCallback onDownloadsTap;
  final VoidCallback onSearchTap;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(ComponentInset.normal.r),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // CREATE PLAYLIST BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: CreatePlaylistButton(onTap: onCreatePlaylistTap),
          ),

          // TITLE
          Container(
            height: ComponentSize.normal.h,
            margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
            child: Text(LocaleResources.of(context).libraryHomeTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.boldHeading1.copyWith(
                  color: DynamicTheme.get(context).white(),
                )),
          ),
          Button(
              width: double.infinity,
              type: ButtonType.secondary,
              text: LocaleResources.of(context).downloads,
              onPressed: onDownloadsTap),
          SizedBox(height: ComponentInset.normal.r),

          // SEARCH
          ScaleTap(
            scaleMinValue: 0.98,
            onPressed: onSearchTap,
            child: AbsorbPointer(
                child: SearchBar(
                    hintText:
                        LocaleResources.of(context).libraryHomeSearchHint)),
          )
        ]));
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.header,
  }) : super(key: key);

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<Track, LibraryHomeModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        headerSlivers: [SliverToBoxAdapter(child: header)],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        emptyFirstPageIndicator: const _EmptyLibraryWidget(),
        itemBuilder: (context, track, index) {
          return TrackListItem(track: track);
        });
  }
}

class _EmptyLibraryWidget extends StatelessWidget {
  const _EmptyLibraryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyIndicator(
      message: LocaleResources.of(context).emptyLibraryMessage,
    );
  }
}
