import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/feed/feed.widget.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/dashboard/widget/titlebar/dashboard_title.widgets.dart';
import 'package:kwotmusic/features/music/genre/selection/music_genre_selection.bottomsheet.dart';
import 'package:kwotmusic/features/search/search.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'music_home.model.dart';

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({Key? key}) : super(key: key);

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends PageState<MusicHomePage>
    with AutomaticKeepAliveClientMixin<MusicHomePage> {
  //=
  late ScrollController _scrollController;

  MusicHomeModel get _musicHomeModel => context.read<MusicHomeModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _musicHomeModel.init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageTitleBarWrapper(
      barHeight: 48.r,
      title: DashboardPageTitle(
          text: LocaleResources.of(context).musicHomeTitle,
          color: DynamicTheme.get(context).white(),
          onTap: _scrollController.animateToTop),
      actions: [
        DashboardPageTitleAction(
            asset: Assets.iconSearch,
            color: DynamicTheme.get(context).neutral20(),
            onTap: _onSearchBarTap),
        _TitleBarSearchFilterIcon(onTap: _onFilterButtonTapped),
      ],
      child: ItemListWidget<Feed, MusicHomeModel>.optionalSeparator(
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.normal.r),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.r),
      _buildSearchBar(),
      _buildSelectedFilterRow(),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }

  Widget _buildTitle() {
    return Container(
      height: ComponentSize.normal.h,
      margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: Text(LocaleResources.of(context).musicHomeTitle,
          style: TextStyles.boldHeading1.copyWith(
            color: DynamicTheme.get(context).white(),
          )),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      child: ScaleTap(
        scaleMinValue: 0.98,
        onPressed: _onSearchBarTap,
        child: Stack(children: [
          AbsorbPointer(
              child: SearchBar(
                  hintText: LocaleResources.of(context).musicHomeSearchHint)),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: _SearchFilterIcon(onTap: _onFilterButtonTapped)),
        ]),
      ),
    );
  }

  Widget _buildSelectedFilterRow() {
    return Selector<MusicHomeModel, List<MusicGenre>?>(
        selector: (_, model) => model.selectedGenres,
        builder: (_, selectedGenres, __) {
          if (selectedGenres == null || selectedGenres.isEmpty) {
            return Container();
          }

          return FilterChipLayout(
            margin: EdgeInsets.only(top: ComponentInset.normal.h),
            items: selectedGenres.map((genre) {
              return FilterChipItem(
                text: genre.title,
                action: () => _musicHomeModel.removeSelectedGenre(genre),
              );
            }).toList(),
          );
        });
  }

  void _onSearchBarTap() {
    DashboardNavigation.pushNamed(context, Routes.search,
        arguments: SearchArgs(source: SearchSource.music));
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final args = _musicHomeModel.selectedGenres;
    final selectedGenres =
        await MusicGenreSelectionBottomSheet.show(context, args);

    if (!mounted) return;
    if (selectedGenres != null) {
      _musicHomeModel.setSelectedGenres(selectedGenres);
      _scrollController.jumpToTop();
    }
  }
}

class _SearchFilterIcon extends StatelessWidget {
  const _SearchFilterIcon({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<MusicHomeModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return FilterIconSuffix(isSelected: filtered, onPressed: onTap);
        });
  }
}

class _TitleBarSearchFilterIcon extends StatelessWidget {
  const _TitleBarSearchFilterIcon({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<MusicHomeModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return DashboardPageTitleAction(
              asset: filtered ? Assets.iconFilterFilled : Assets.iconFilter,
              color: filtered
                  ? DynamicTheme.get(context).secondary100()
                  : DynamicTheme.get(context).neutral20(),
              onTap: onTap);
        });
  }
}
