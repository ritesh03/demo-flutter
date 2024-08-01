import 'package:flutter/material.dart'  hide SearchBar;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/notificationbar/notification_bar.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_text.widget.dart';
import 'package:kwotmusic/components/widgets/page/title/page_title_bar_wrapper.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/playback/widget/playbutton/downloads_play_button.widget.dart';
import 'package:kwotmusic/features/track/download/track_download_status.widget.dart';
import 'package:kwotmusic/features/track/widget/track_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

import 'downloads.model.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({Key? key}) : super(key: key);

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends PageState<DownloadsPage> {
  //=
  late ScrollController _scrollController;
  late FocusNode _searchInputFocusNode;

  DownloadsModel get _downloadsModel => context.read<DownloadsModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchInputFocusNode = FocusNode();

    _downloadsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _DownloadsPageFloatingTitleBar(
          onTitleTap: _scrollController.animateToTop,
          onSearchTap: _onSearchIconTap,
          child: _ItemList(
            controller: _scrollController,
            header: _ItemListHeader(
              searchInputFocusNode: _searchInputFocusNode,
              onBackTap: onBackTap,
            ),
            onTrackTap: _onTrackTap,
          ),
        ),
      ),
    );
  }

  void onBackTap() {
    DashboardNavigation.pop(context);
  }

  void _onSearchIconTap() {
    _scrollController.animateToTop().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(_searchInputFocusNode);
      });
    });
  }

  bool _onTrackTap(Track track) {
    final downloadedFilePath =
        locator<KwotData>().downloadManager.getDownloadedFilePath(track.id);
    if (downloadedFilePath == null) {
      final error = LocaleResources.of(context).errorDownloadIsNotComplete;
      showDefaultNotificationBar(NotificationBarInfo.error(message: error));
      return true;
    }

    locator<AudioPlaybackActionsModel>().playDownloads(track: track);
    return true;
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    Key? key,
    required this.controller,
    required this.header,
    required this.onTrackTap,
  }) : super(key: key);

  final ScrollController controller;
  final Widget header;
  final bool Function(Track) onTrackTap;

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<Track, DownloadsModel>(
        controller: controller,
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        headerSlivers: [SliverToBoxAdapter(child: header)],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        emptyFirstPageIndicator: const _EmptyDownloadsWidget(),
        itemBuilder: (context, track, index) {
          return TrackListItem(
            track: track,
            trailing: TrackDownloadStatusWidget(track: track),
            onTap: onTrackTap,
          );
        });
  }
}

class _ItemListHeader extends StatelessWidget {
  const _ItemListHeader({
    Key? key,
    required this.searchInputFocusNode,
    required this.onBackTap,
  }) : super(key: key);

  final FocusNode searchInputFocusNode;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _DownloadsPageTitleBar(onBackTap: onBackTap),
      SizedBox(height: ComponentInset.small.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: const _DownloadsPageTitleText(),
      ),
      SizedBox(height: ComponentInset.normal.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: _DownloadsPageSearchBar(focusNode: searchInputFocusNode),
      ),
      SizedBox(height: ComponentInset.normal.h),
    ]);
  }
}

class _DownloadsPageFloatingTitleBar extends StatelessWidget {
  const _DownloadsPageFloatingTitleBar({
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
        title: PageTitleBarText(
            text: LocaleResources.of(context).downloadsPageTitle,
            color: DynamicTheme.get(context).white(),
            onTap: onTitleTap),
        centerTitle: false,
        actions: [
          const _DownloadsPlayButton(),
          SizedBox(width: ComponentInset.small.r),
        ],
        child: child);
  }
}

class _DownloadsPageTitleBar extends StatelessWidget {
  const _DownloadsPageTitleBar({
    Key? key,
    required this.onBackTap,
  }) : super(key: key);

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentSize.large.h,
      child: Row(children: [
        AppIconButton(
            width: ComponentSize.large.r,
            height: ComponentSize.large.r,
            assetColor: DynamicTheme.get(context).neutral20(),
            assetPath: Assets.iconArrowLeft,
            padding: EdgeInsets.all(ComponentInset.small.r),
            onPressed: onBackTap),
        const Spacer(),
        const _DownloadsPlayButton(),
        SizedBox(width: ComponentInset.small.r),
      ]),
    );
  }
}

class _DownloadsPageTitleText extends StatelessWidget {
  const _DownloadsPageTitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(LocaleResources.of(context).downloadsPageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2.copyWith(
          color: DynamicTheme.get(context).white(),
        ));
  }
}

class _DownloadsPageSearchBar extends StatelessWidget {
  const _DownloadsPageSearchBar({
    Key? key,
    required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      focusNode: focusNode,
      hintText: LocaleResources.of(context).downloadsPageSearchHint,
      onQueryChanged: context.read<DownloadsModel>().updateSearchQuery,
      onQueryCleared: context.read<DownloadsModel>().clearSearchQuery,
    );
  }
}

class _EmptyDownloadsWidget extends StatelessWidget {
  const _EmptyDownloadsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<DownloadsModel, bool>(selector: (_, model) {
      return model.searchQuery != null && model.searchQuery!.isNotEmpty;
    }, builder: (context, hasSearchQuery, _) {
      if (hasSearchQuery) {
        return const EmptyIndicator();
      }

      return StreamBuilder(
          stream: InternetConnectionChecker().onStatusChange.distinct(),
          builder: (_, snapshot) {
            final status = snapshot.data as InternetConnectionStatus?;
            switch (status) {
              case null:
                return const EmptyIndicator();
              case InternetConnectionStatus.connected:
                return EmptyIndicator(
                    message: LocaleResources.of(context)
                        .emptyDownloadsMessageWhenOnline);
              case InternetConnectionStatus.disconnected:
                return EmptyIndicator(
                    message: LocaleResources.of(context)
                        .emptyDownloadsMessageWhenOffline);
            }
          });
    });
  }
}

class _DownloadsPlayButton extends StatelessWidget {
  const _DownloadsPlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<DownloadsModel, bool>(
        selector: (_, model) => model.totalDownloads > 0,
        builder: (_, hasDownloads, __) {
          if (!hasDownloads) return const SizedBox.shrink();
          return DownloadsPlayButton(size: ComponentSize.normal.r);
        });
  }
}
