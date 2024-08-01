import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/blocking_progress.dialog.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/chip/chip_selection_layout.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/segmented_control_tabs.widget.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/search/search_catalog.usecase.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'search.model.dart';
import 'search.page.actions.dart';
import 'search_actions.model.dart';
import 'widget/recent_search_list_item.widget.dart';
import 'widget/search_result_list_item.widget.dart';
import 'widget/trending_search_list_item.widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends PageState<SearchPage>
    implements SearchPageActionCallback {
  //=

  late FocusNode _searchInputFocusNode;

  SearchModel get searchModel => context.read<SearchModel>();

  SearchActionsModel get searchActionsModel => locator<SearchActionsModel>();

  @override
  void initState() {
    super.initState();
    _searchInputFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_searchInputFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.normal.h),
                child: _buildAppBar()),
            body: Column(children: [
              // SizedBox(height: ComponentInset.normal.r),
              // _buildSearchPlaceTabs(),
              SizedBox(height: ComponentInset.normal.r),
              _buildSearchKindFilters(),
              SizedBox(height: ComponentInset.normal.r),
              const _EmptySearchResultsBar(),
              _SearchItemListHeader(callback: this),
              Expanded(child: _SearchResultItemList(callback: this)),
            ])));
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.normal.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: onBackPressed),
      Expanded(child: _buildSearchBar()),
      SizedBox(width: ComponentInset.normal.w),
    ]);
  }

  Widget _buildSearchBar() {
    return SearchBar(
        focusNode: _searchInputFocusNode,
        hintText: LocaleResources.of(context).searchPageSearchHint,
        onQueryChanged: searchModel.updateSearchQuery,
        onQueryCleared: () => searchModel.updateSearchQuery(null));
  }

  Widget _buildSearchPlaceTabs() {
    /// TODO: selector from provider?
    return SegmentedControlTabsWidget<SearchPlace>(
      items: SearchPlace.values,
      height: ComponentSize.normal.h,
      margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
      itemTitle: (place) {
        return searchActionsModel.getSearchPlaceText(context, place);
      },
      onChanged: searchModel.updateSearchPlace,
      selectedItemIndex: searchModel.searchPlace.index,
    );
  }

  Widget _buildSearchKindFilters() {
    /// initiate the list with null value to show
    /// 'All' section of search.
    final kinds = <SearchKind?>[null];

    for (final kind in SearchKind.values) {
      if (kind == SearchKind.radioStation) continue;
      if (kind == SearchKind.show) continue;
      kinds.add(kind);
    }

    return Selector<SearchModel, SearchKind?>(
        selector: (_, model) => model.searchKind,
        builder: (_, selectedSearchKind, __) {
          return ChipSelectionLayoutWidget<SearchKind?>(
              height: ComponentSize.normal.h,
              items: kinds,
              itemTitle: (kind) {
                return searchActionsModel.getSearchKindText(context,
                    kind: kind, plural: true);
              },
              itemInnerSpacing: ComponentInset.small.r,
              itemOuterSpacing: ComponentInset.normal.r,
              onItemSelect: searchModel.updateSearchKind,
              selectedItem: selectedSearchKind);
        });
  }

  @override
  void onBackPressed() {
    hideKeyboard(context);

    DashboardNavigation.pop(context);
  }

  @override
  void onSearchResultItemTap(SearchResultItem item) {
    hideKeyboard(context);

    searchActionsModel.addSearchResultToRecentSearch(item: item);
    searchActionsModel.handleSearchResultItemTap(context, item: item);
  }

  @override
  void onSearchResultItemOptionsTap(SearchResultItem item) {
    hideKeyboard(context);

    searchActionsModel.handleSearchResultItemOptionsTap(context, item: item);
  }

  @override
  void onRecentSearchResultItemTap(SearchResultItem item) {
    hideKeyboard(context);

    searchActionsModel.handleSearchResultItemTap(context, item: item);
  }

  @override
  void onRemoveRecentSearchResultItemTap(SearchResultItem item) async {
    hideKeyboard(context);

    showBlockingProgressDialog(context);
    final result = await searchActionsModel.removeRecentSearchResultItem(
      item: item,
    );

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // handled by eventbus events
  }

  @override
  void onClearRecentSearchesTap() async {
    hideKeyboard(context);

    showBlockingProgressDialog(context);
    final result = await searchActionsModel.clearRecentSearches();

    if (!mounted) return;
    hideBlockingProgressDialog(context);

    if (!result.isSuccess()) {
      showDefaultNotificationBar(
          NotificationBarInfo.error(message: result.error()));
      return;
    }

    // handled by eventbus events
  }
}

class _SearchItemListHeader extends StatelessWidget {
  const _SearchItemListHeader({
    Key? key,
    required this.callback,
  }) : super(key: key);

  final SearchPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: ComponentSize.small.r,
        margin: EdgeInsets.only(
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.small.r),
        child: Row(children: [
          const Expanded(child: _SearchItemListHeaderText()),
          _ClearRecentSearchesButton(onTap: callback.onClearRecentSearchesTap),
        ]));
  }
}

class _SearchItemListHeaderText extends StatelessWidget {
  const _SearchItemListHeaderText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchModel, SearchCatalogType>(
        selector: (_, model) => model.searchCatalogType,
        builder: (context, searchCatalogType, __) {
          final localization = LocaleResources.of(context);

          String text;
          switch (searchCatalogType) {
            case SearchCatalogType.searchResults:
              text = localization.searchResultsPanelTitle;
              break;
            case SearchCatalogType.recentSearches:
              text = localization.recentSearchesPanelTitle;
              break;
            case SearchCatalogType.trendingSearches:
              text = localization.trendingSearchesPanelTitle;
              break;
          }

          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading4
                .copyWith(color: DynamicTheme.get(context).white()),
          );
        });
  }
}

class _ClearRecentSearchesButton extends StatelessWidget {
  const _ClearRecentSearchesButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Selector<SearchModel, bool>(
        selector: (_, model) => model.canShowClearRecentSearchesOption,
        builder: (context, canShow, __) {
          if (!canShow) return Container();
          return Button(
              height: ComponentSize.small.r,
              onPressed: onTap,
              text: LocaleResources.of(context).recentSearchesClearAll,
              type: ButtonType.text);
        });
  }
}

class _EmptySearchResultsBar extends StatelessWidget {
  const _EmptySearchResultsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchModel, bool>(
      selector: (_, model) => model.hasEmptySearchResults,
      builder: (_, hasEmptySearchResults, __) {
        if (!hasEmptySearchResults) return const SizedBox.shrink();
        return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
            margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
            child: Text(LocaleResources.of(context).emptySearchResults,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.heading4
                    .copyWith(color: DynamicTheme.get(context).white())));
      },
    );
  }
}

class _SearchResultItemList extends StatelessWidget {
  const _SearchResultItemList({
    Key? key,
    required this.callback,
  }) : super(key: key);

  final SearchPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    return Selector<SearchModel, Tuple2<SearchCatalogType, String?>>(
        selector: (_, model) =>
            Tuple2(model.searchCatalogType, model.searchQuery),
        builder: (_, tuple, __) {
          final searchCatalogType = tuple.item1;
          final searchQuery = tuple.item2;

          return ItemListWidget<SearchResultItem, SearchModel>(
              columnItemSpacing: ComponentInset.normal.r,
              padding:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
              footerSlivers: [DashboardConfigAwareFooter.asSliver()],
              itemBuilder: (context, searchItem, index) {
                switch (searchCatalogType) {
                  case SearchCatalogType.searchResults:
                    return SearchResultListItem(
                        item: searchItem,
                        query: searchQuery,
                        onTap: callback.onSearchResultItemTap,
                        onOptionsTap: searchItem.hasOptions
                            ? callback.onSearchResultItemOptionsTap
                            : null);
                  case SearchCatalogType.recentSearches:
                    return RecentSearchListItem(
                        item: searchItem,
                        onTap: () =>
                            callback.onRecentSearchResultItemTap(searchItem),
                        onRemoveTap: () => callback
                            .onRemoveRecentSearchResultItemTap(searchItem));
                  case SearchCatalogType.trendingSearches:
                    return TrendingSearchListItem(
                        item: searchItem,
                        onTap: callback.onSearchResultItemTap,
                        onOptionsTap: searchItem.hasOptions
                            ? callback.onSearchResultItemOptionsTap
                            : null);
                }
              });
        });
  }
}
