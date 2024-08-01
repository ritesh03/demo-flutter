import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/chip/multi_chip_selection_layout.widget.dart';
import 'package:kwotmusic/components/widgets/feed/feed.widget.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/music/genre/selection/music_genre_selection.bottomsheet.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'music_browser.model.dart';

class MusicBrowserPage extends StatefulWidget {
  const MusicBrowserPage({Key? key}) : super(key: key);

  @override
  State<MusicBrowserPage> createState() => _MusicBrowserPageState();
}

class _MusicBrowserPageState extends PageState<MusicBrowserPage> {
  //=
  MusicBrowserModel get _musicBrowserModel => context.read<MusicBrowserModel>();

  @override
  void initState() {
    super.initState();
    _musicBrowserModel.init();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ComponentSize.large.h),
            child: _buildAppBar()),
        body: _MusicBrowseKindOptionsLoader(child: _buildItemList()),
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

  /*
   * BODY
   */

  Widget _buildItemList() {
    return ItemListWidget<Feed, MusicBrowserModel>.optionalSeparator(
        columnItemSpacing: ComponentInset.medium.r,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, feed, index) {
          return FeedWidget(feed: feed, itemSpacing: ComponentInset.normal.r);
        },
        shouldShowListItemSeparator: (feed, index) {
          return !feed.isEmpty;
        });
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: ComponentInset.small.r),
      _buildTitle(),
      SizedBox(height: ComponentInset.normal.r),
      _buildSearchBar(),
      SizedBox(height: ComponentInset.normal.r),
      const _MusicBrowseKindOptionsStrip(),
      SizedBox(height: ComponentInset.normal.r),
    ]);
  }

  Widget _buildTitle() {
    final localization = LocaleResources.of(context);
    return Container(
        height: ComponentSize.small.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Selector<MusicBrowserModel, MusicBrowseKind?>(
            selector: (_, model) => model.browseKind,
            builder: (_, browseKind, __) {
              final String title;
              if (browseKind == null) {
                title = localization.browseBy;
              } else {
                title = localization.browseByKindFormat(browseKind.title);
              }
              return SimpleMarquee(
                text: title,
                textStyle: TextStyles.boldHeading2
                    .copyWith(color: DynamicTheme.get(context).white()),
              );
            }));
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: SearchBar(
          hintText: LocaleResources.of(context).browseMusicSearchHint,
          onQueryChanged: _musicBrowserModel.updateSearchQuery,
          onQueryCleared: _musicBrowserModel.clearSearchQuery,
          suffixes: [
            _SearchFilterIcon(onTap: _onFilterButtonTapped),
          ],
        ));
  }

  void _onFilterButtonTapped() async {
    hideKeyboard(context);

    final args = _musicBrowserModel.selectedGenres;
    final selectedGenres =
        await MusicGenreSelectionBottomSheet.show(context, args);

    if (!mounted) return;
    if (selectedGenres != null) {
      _musicBrowserModel.setSelectedGenres(selectedGenres);
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
    return Selector<MusicBrowserModel, bool>(
        selector: (_, model) => model.filtered,
        builder: (_, filtered, __) {
          return FilterIconSuffix(isSelected: filtered, onPressed: onTap);
        });
  }
}

class _MusicBrowseKindOptionsLoader extends StatelessWidget {
  const _MusicBrowseKindOptionsLoader({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  MusicBrowserModel modelOf(BuildContext context) {
    return context.read<MusicBrowserModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MusicBrowserModel, Result<MusicBrowseKindWithOptions>?>(
        selector: (_, model) => model.browseKindAndOptionsResult,
        builder: (_, result, __) {
          if (result == null) {
            return const LoadingIndicator();
          }

          if (!result.isSuccess()) {
            return Center(
              child: ErrorIndicator(
                error: result.error(),
                onTryAgain: () => modelOf(context).fetchBrowseKindAndOptions(),
              ),
            );
          }

          return child;
        });
  }
}

class _MusicBrowseKindOptionsStrip extends StatelessWidget {
  const _MusicBrowseKindOptionsStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MusicBrowserModel, List<MusicBrowseKindOption>>(
        selector: (_, model) => model.browseKindOptions,
        builder: (_, browseKindOptions, __) {
          final availableBrowseKindOptions = <MusicBrowseKindOption?>[
            null,
            ...browseKindOptions,
          ];

          return MultiChipSelectionLayoutWidget<MusicBrowseKindOption?>(
            height: ComponentSize.normal.h,
            items: availableBrowseKindOptions,
            itemTitle: (browseKindOption) {
              if (browseKindOption == null) {
                return LocaleResources.of(context).all;
              }

              return browseKindOption.title;
            },
            itemInnerSpacing: ComponentInset.small.r,
            itemOuterSpacing: ComponentInset.normal.r,
            onItemTap: (item) {
              context
                  .read<MusicBrowserModel>()
                  .updateSelectedBrowseKindOptionsWith(item);
              return _createSelectedItems(context);
            },
            selectedItems: _createSelectedItems(context),
          );
        });
  }

  List<MusicBrowseKindOption?> _createSelectedItems(BuildContext context) {
    final selectedItems = <MusicBrowseKindOption?>[
      ...context.read<MusicBrowserModel>().selectedBrowseKindOptions,
    ];
    if (selectedItems.isEmpty) {
      selectedItems.add(null);
    }
    return selectedItems;
  }
}
