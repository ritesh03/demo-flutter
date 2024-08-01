import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield/search/searchbar.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/music/browsekindoptions/widget/music_browse_kind_option_grid_item.widget.dart';
import 'package:kwotmusic/features/music/browser/music_browser.args.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';

import 'music_browse_kind_options.model.dart';

class MusicBrowseKindOptionsPage extends StatefulWidget {
  const MusicBrowseKindOptionsPage({Key? key}) : super(key: key);

  @override
  State<MusicBrowseKindOptionsPage> createState() =>
      _MusicBrowseKindOptionsPageState();
}

class _MusicBrowseKindOptionsPageState
    extends PageState<MusicBrowseKindOptionsPage> {
  //=
  MusicBrowseKindOptionsModel get _browseKindOptionsModel =>
      context.read<MusicBrowseKindOptionsModel>();

  @override
  void initState() {
    super.initState();
    _browseKindOptionsModel.init();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar()),
        body: RefreshIndicator(
          color: DynamicTheme.get(context).secondary100(),
          backgroundColor: DynamicTheme.get(context).black(),
          onRefresh: () => _browseKindOptionsModel.refresh(),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
                padding:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                sliver: _buildItemList()),
            DashboardConfigAwareFooter.asSliver(),
          ]),
        ),
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
        child: Selector<MusicBrowseKindOptionsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, title, __) {
              return SimpleMarquee(
                  text: title ?? LocaleResources.of(context).browseBy,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).search,
          onQueryChanged: _browseKindOptionsModel.updateSearchQuery,
          onQueryCleared: _browseKindOptionsModel.clearSearchQuery,
        ));
  }

  Widget _buildItemList() {
    return Selector<MusicBrowseKindOptionsModel,
            Result<List<MusicBrowseKindOption>>?>(
        selector: (_, model) => model.browseKindOptionsResult,
        builder: (_, result, __) {
          if (result == null) {
            return const SliverFillRemaining(child: LoadingIndicator());
          }

          if (!result.isSuccess()) {
            return SliverFillRemaining(
              child: ErrorIndicator(
                error: result.error(),
                onTryAgain: () =>
                    _browseKindOptionsModel.fetchMusicBrowseKindOptions(),
              ),
            );
          }

          final items = result.peek();
          if (items == null || items.isEmpty) {
            return const SliverFillRemaining(child: EmptyIndicator());
          }

          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                final browseKindOption = items[index];
                return MusicBrowseKindOptionGridItem(
                  width: null,
                  option: browseKindOption,
                  onTap: () => _onBrowseKindOptionTapped(browseKindOption),
                );
              },
              childCount: items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: ComponentInset.normal.r,
              crossAxisSpacing: ComponentInset.normal.r,
            ),
          );
        });
  }

  void _onBrowseKindOptionTapped(MusicBrowseKindOption browseKindOption) {
    DashboardNavigation.pushNamed(
      context,
      Routes.musicBrowser,
      arguments: MusicBrowserArgs(
        browseKindId: browseKindOption.kindId,
        browseKindOptionId: browseKindOption.id,
      ),
    );
  }
}
