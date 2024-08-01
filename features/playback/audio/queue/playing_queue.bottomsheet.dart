import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/features/playback/audio/queue/playing_queue.model.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/util/util.dart';
import 'package:provider/provider.dart';

class PlayingQueueBottomSheet extends StatefulWidget {
  //=
  static Future show(BuildContext context) {
    return showMaterialBottomSheet<void>(
      context,
      builder: (_, controller) {
        return ChangeNotifierProvider(
            create: (_) => PlayingQueueModel(),
            child: PlayingQueueBottomSheet(controller: controller));
      },
    );
  }

  const PlayingQueueBottomSheet({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ScrollController controller;

  @override
  State<PlayingQueueBottomSheet> createState() =>
      _PlayingQueueBottomSheetState();
}

class _PlayingQueueBottomSheetState extends PageState<PlayingQueueBottomSheet> {
  //=
  PlayingQueueModel get _playingQueueModel => context.read<PlayingQueueModel>();

  @override
  void initState() {
    super.initState();
    _playingQueueModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        EdgeInsets.symmetric(horizontal: ComponentInset.normal.r);
    return Column(children: [
      const BottomSheetDragHandle(),
      SizedBox(height: ComponentInset.small.r),
      _TitleBar(padding: horizontalPadding),
      SizedBox(height: ComponentInset.normal.r),
      Expanded(
        child: _PlayingQueueItemsList(
          controller: widget.controller,
          padding: horizontalPadding,
        ),
      ),
    ]);
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ComponentSize.normal.r,
      padding: padding,
      child: Row(children: [
        Expanded(
          child: Text(
            LocaleResources.of(context).playingQueue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldHeading3
                .copyWith(color: DynamicTheme.get(context).white()),
          ),
        ),
        const _ClearPlayingQueueButton(),
      ]),
    );
  }
}

class _ClearPlayingQueueButton extends StatelessWidget {
  const _ClearPlayingQueueButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<PlayingQueueModel, bool>(
        selector: (_, model) => model.canClearPlayingQueue,
        builder: (_, canClear, __) {
          return Button(
              enabled: canClear,
              text: LocaleResources.of(context).clear,
              height: ComponentSize.normal.r,
              type: ButtonType.text,
              onPressed: () {
                context.read<PlayingQueueModel>().clearPlayingQueue();
              });
        });
  }
}

class _PlayingQueueHeader extends StatelessWidget {
  const _PlayingQueueHeader({
    Key? key,
    required this.padding,
  }) : super(key: key);

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Padding(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // NOW PLAYING:
        const _NowPlayingSection(),
        SizedBox(height: ComponentInset.normal.r),

        // NEXT PLAYING:
        _NextPlayingSection(title: localization.nextPlayingSectionTitle),
        SizedBox(height: ComponentInset.normal.r),
      ]),
    );
  }
}

class _SectionTitleChip extends StatelessWidget {
  const _SectionTitleChip({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).background(),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        padding: EdgeInsets.all(ComponentInset.small.r),
        child: Text(title, style: TextStyles.heading6));
  }
}

class _NowPlayingSection extends StatelessWidget {
  const _NowPlayingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlaybackItem?>(
      valueListenable: audioPlayerManager.playbackItemNotifier,
      builder: (_, playbackItem, __) {
        if (playbackItem == null) {
          return const SizedBox.shrink();
        }

        final sectionTitle = LocaleResources.of(context).nowPlayingSectionTitle;
        return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _SectionTitleChip(title: sectionTitle),
                const Spacer(),
                // TODO: fix shuffle issue (misses playing next song after shuffle-update) on playing-queue page
                // const PlaybackShuffleButton(),
                // SizedBox(width: ComponentInset.normal.r),
                const PlaybackRepeatButton(),
              ]),
              SizedBox(height: ComponentInset.normal.r),
              PlayQueueListItem(playbackItem: playbackItem, isPlaying: true),
            ]);
      },
    );
  }
}

class _NextPlayingSection extends StatelessWidget {
  const _NextPlayingSection({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Selector<PlayingQueueModel, int?>(
        selector: (_, model) => model.nextPlayingItemCount,
        builder: (_, count, __) {
          if (count != null && count <= 0) {
            return const SizedBox.shrink();
          }

          return _SectionTitleChip(title: title);
        });
  }
}

class _PlayingQueueItemsList extends StatelessWidget {
  const _PlayingQueueItemsList({
    Key? key,
    required this.controller,
    required this.padding,
  }) : super(key: key);

  final ScrollController controller;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final basePaddingValue = padding.left;
    final listPadding = EdgeInsets.only(
      left: basePaddingValue,
      right: basePaddingValue,
      bottom: basePaddingValue,
    );

    return Selector<PlayingQueueModel, int>(
        selector: (_, model) => model.currentPlayingItemIndex,
        builder: (_, playingItemIndex, __) {
          return ItemListWidget<PlaybackItem,
              PlayingQueueModel>.optionalSeparator(
            controller: controller,
            columnItemSpacing: ComponentInset.normal.r,
            headerSlivers: [
              SliverToBoxAdapter(child: _PlayingQueueHeader(padding: padding)),
            ],
            padding: listPadding,
            useRefreshIndicator: false,
            itemBuilder: (context, playbackItem, index) {
              if (index <= playingItemIndex) {
                return const SizedBox.shrink();
              }

              return PlayQueueListItem(
                playbackItem: playbackItem,
                onTap: () => _onItemTap(index),
              );
            },
            shouldShowListItemSeparator: (_, index) {
              return index > playingItemIndex;
            },
          );
        });
  }

  void _onItemTap(int index) {
    audioPlayerManager.skipToIndex(index);
    controller.jumpToTop();
  }
}
