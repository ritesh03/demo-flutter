import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/components/widgets/list/item_list_view_mode.widget.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_action.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playlist/detail/playlist.args.dart';
import 'package:kwotmusic/features/playlist/list/playlists.args.dart';
import 'package:kwotmusic/features/playlist/list/playlists.page.actions.dart';
import 'package:kwotmusic/features/playlist/widget/create_playlist_button.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_grid_item.widget.dart';
import 'package:kwotmusic/features/playlist/widget/playlist_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'playlists.model.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({Key? key}) : super(key: key);

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends PageState<PlaylistsPage>
    implements PlaylistsPageActionCallback {
  //=
  late ScrollController _scrollController;
  late FocusNode _searchInputFocusNode;

  PlaylistsModel get _playlistsModel => context.read<PlaylistsModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchInputFocusNode = FocusNode();

    _playlistsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _PlaylistsPageFloatingTitleBar(
          onTitleTap: _scrollController.animateToTop,
          onSearchTap: _onSearchIconTap,
          child: _ItemList(
            controller: _scrollController,
            callback: this,
            header: _ItemListHeader(
              searchInputFocusNode: _searchInputFocusNode,
              callback: this,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onBackTap() {
    DashboardNavigation.pop(context);
  }

  @override
  void onCreatePlaylistTap() {
    hideKeyboard(context);
    DashboardNavigation.pushNamed(context, Routes.createOrEditPlaylist);
  }

  @override
  void onPlaylistTap(Playlist playlist) {
    hideKeyboard(context);

    final thumbnail = playlist.images.isEmpty ? null : playlist.images.first;
    final args = PlaylistArgs(
        id: playlist.id, thumbnail: thumbnail, title: playlist.name);
    DashboardNavigation.pushNamed(context, Routes.playlist, arguments: args);
  }

  void _onSearchIconTap() {
    _scrollController.animateToTop().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(_searchInputFocusNode);
      });
    });
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.controller,
    required this.header,
    required this.callback,
  }) : super(key: key);

  final ScrollController controller;
  final Widget header;
  final PlaylistsPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistsModel, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return ItemListWidget<Playlist, PlaylistsModel>(
              controller: controller,
              columnItemSpacing: ComponentInset.normal.h,
              padding:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
              columnCount: viewMode.columnCount,
              headerSlivers: [SliverToBoxAdapter(child: header)],
              footerSlivers: [DashboardConfigAwareFooter.asSliver()],
              itemBuilder: (context, playlist, index) {
                switch (viewMode) {
                  case ItemListViewMode.list:
                    return PlaylistListItem(
                      playlist: playlist,
                      onTap: () => callback.onPlaylistTap(playlist),
                    );
                  case ItemListViewMode.grid:
                    return PlaylistGridItem(
                      width: 0.5.sw,
                      playlist: playlist,
                      onTap: () => callback.onPlaylistTap(playlist),
                    );
                }
              });
        });
  }
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader({
    Key? key,
    this.searchInputFocusNode,
    required this.callback,
  }) : super(key: key);

  final FocusNode? searchInputFocusNode;
  final PlaylistsPageActionCallback callback;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PlaylistsPageTitleBar(
        onBackTap: callback.onBackTap,
        onCreatePlaylistTap: callback.onCreatePlaylistTap,
      ),
      SizedBox(height: ComponentInset.small.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: const _PlaylistsPageTitleText(),
      ),
      SizedBox(height: ComponentInset.normal.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: _PlaylistsSearchBar(focusNode: searchInputFocusNode),
      ),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }
}

class _PlaylistsPageFloatingTitleBar extends StatelessWidget {
  const _PlaylistsPageFloatingTitleBar({
    Key? key,
    required this.onTitleTap,
    required this.onSearchTap,
    required this.child,
  }) : super(key: key);

  final VoidCallback onTitleTap;
  final VoidCallback onSearchTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTitleBarWrapper(
        barHeight: ComponentSize.large.r,
        title: Selector<PlaylistsModel, PlaylistsArgs?>(
            selector: (_, model) => model.args,
            builder: (_, args, __) => PageTitleBarText(
                text: context.read<PlaylistsModel>().getPageTitle(context),
                color: DynamicTheme.get(context).white(),
                onTap: onTitleTap)),
        centerTitle: false,
        actions: [
          PageTitleIconAction(
              asset: Assets.iconSearch,
              color: DynamicTheme.get(context).neutral20(),
              onTap: onSearchTap),
        ],
        child: child);
  }
}

class _PlaylistsPageTitleBar extends StatelessWidget {
  const _PlaylistsPageTitleBar({
    Key? key,
    required this.onBackTap,
    required this.onCreatePlaylistTap,
  }) : super(key: key);

  final VoidCallback onBackTap;
  final VoidCallback onCreatePlaylistTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.large.h,
      child: Stack(alignment: Alignment.center, children: [
        Row(children: [
          AppIconButton(
              width: ComponentSize.large.r,
              height: ComponentSize.large.r,
              assetColor: DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconArrowLeft,
              padding: EdgeInsets.all(ComponentInset.small.r),
              onPressed: onBackTap),
          const Spacer(),
          const ItemListViewModeWidget<PlaylistsModel>(),
          SizedBox(width: ComponentInset.small.w)
        ]),
        CreatePlaylistButton(onTap: onCreatePlaylistTap),
      ]),
    );
  }
}

class _PlaylistsPageTitleText extends StatelessWidget {
  const _PlaylistsPageTitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistsModel, PlaylistsArgs?>(
        selector: (_, model) => model.args,
        builder: (_, args, __) {
          return SimpleMarquee(
              text: context.read<PlaylistsModel>().getPageTitle(context),
              textStyle: TextStyles.boldHeading2.copyWith(
                color: DynamicTheme.get(context).white(),
              ));
        });
  }
}

class _PlaylistsSearchBar extends StatelessWidget {
  const _PlaylistsSearchBar({
    Key? key,
    this.focusNode,
  }) : super(key: key);

  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      focusNode: focusNode,
      hintText: LocaleResources.of(context).playlistsSearchHint,
      onQueryChanged: context.read<PlaylistsModel>().updateSearchQuery,
      onQueryCleared: context.read<PlaylistsModel>().clearSearchQuery,
    );
  }
}
