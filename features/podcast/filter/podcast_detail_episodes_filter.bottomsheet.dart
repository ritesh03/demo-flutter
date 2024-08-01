import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_selectable_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PodcastDetailEpisodesFilterBottomSheet extends StatefulWidget {
  //=
  static Future<PodcastEpisodeFilter?> show(
    BuildContext context, {
    required PodcastEpisodeFilter filter,
  }) {
    return showMaterialBottomSheet<PodcastEpisodeFilter>(
      context,
      expand: false,
      builder: (_, __) =>
          PodcastDetailEpisodesFilterBottomSheet(filter: filter),
    );
  }

  const PodcastDetailEpisodesFilterBottomSheet({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final PodcastEpisodeFilter filter;

  @override
  State<PodcastDetailEpisodesFilterBottomSheet> createState() =>
      _PodcastDetailEpisodesFilterBottomSheetState();
}

class _PodcastDetailEpisodesFilterBottomSheetState
    extends State<PodcastDetailEpisodesFilterBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),

          // /// FILTER BY
          // Text(localization.filterBy, style: TextStyles.boldBody),
          // SizedBox(height: ComponentInset.medium.h),
          //
          // /// FILTER BY: ALL EPISODES
          // BottomSheetSelectableTile(
          //   text: localization.allEpisodesFilterOption,
          //   onTap: _onAllEpisodesFilterTapped,
          //   isSelected:
          //       !widget.filter.downloadedOnly && !widget.filter.unplayedOnly,
          // ),
          // SizedBox(height: ComponentInset.small.h),
          //
          // /// FILTER BY: DOWNLOADED EPISODES
          // BottomSheetSelectableTile(
          //     text: localization.downloadedEpisodesFilterOption,
          //     onTap: _onDownloadedEpisodesFilterTapped,
          //     isSelected: widget.filter.downloadedOnly),
          // SizedBox(height: ComponentInset.small.h),
          //
          // /// FILTER BY: UNPLAYED EPISODES
          // BottomSheetSelectableTile(
          //     text: localization.unplayedEpisodesFilterOption,
          //     onTap: _onUnplayedEpisodesFilterTapped,
          //     isSelected: widget.filter.unplayedOnly),
          // SizedBox(height: ComponentInset.large.h),

          /// SORT BY
          Text(localization.sortBy, style: TextStyles.boldBody),
          SizedBox(height: ComponentInset.medium.h),

          /// SORT BY: NEWEST TO OLDEST
          BottomSheetSelectableTile(
              text: localization.newestToOldestSortOption,
              onTap: () => _onSortOrderTapped(
                  PodcastEpisodeDateSortOrder.newestToOldest),
              isSelected: (widget.filter.sortOrder ==
                  PodcastEpisodeDateSortOrder.newestToOldest)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: OLDEST TO NEWEST
          BottomSheetSelectableTile(
              text: localization.oldestToNewestSortOption,
              onTap: () => _onSortOrderTapped(
                  PodcastEpisodeDateSortOrder.oldestToNewest),
              isSelected: (widget.filter.sortOrder ==
                  PodcastEpisodeDateSortOrder.oldestToNewest)),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  void _onAllEpisodesFilterTapped() {
    RootNavigation.pop(
        context,
        widget.filter.copyWith(
          downloadedOnly: false,
          unplayedOnly: false,
        ));
  }

  void _onDownloadedEpisodesFilterTapped() {
    RootNavigation.pop(
        context,
        widget.filter.copyWith(
          downloadedOnly: !widget.filter.downloadedOnly,
        ));
  }

  void _onUnplayedEpisodesFilterTapped() {
    RootNavigation.pop(
        context,
        widget.filter.copyWith(
          unplayedOnly: !widget.filter.unplayedOnly,
        ));
  }

  void _onSortOrderTapped(PodcastEpisodeDateSortOrder sortOrder) {
    RootNavigation.pop(context, widget.filter.copyWith(sortOrder: sortOrder));
  }
}
