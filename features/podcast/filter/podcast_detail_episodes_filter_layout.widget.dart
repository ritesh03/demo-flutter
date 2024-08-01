import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PodcastDetailEpisodesFilterLayout extends StatelessWidget {
  const PodcastDetailEpisodesFilterLayout({
    Key? key,
    required this.episodeFilter,
    required this.onResetDownloadedOnly,
    required this.onResetUnplayedOnly,
    required this.onResetSortOrder,
    this.margin,
  }) : super(key: key);

  final PodcastEpisodeFilter episodeFilter;
  final VoidCallback onResetDownloadedOnly;
  final VoidCallback onResetUnplayedOnly;
  final VoidCallback onResetSortOrder;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FilterChipLayout(
      items: _createItems(context),
      margin: margin,
    );
  }

  List<FilterChipItem> _createItems(BuildContext context) {
    final localization = LocaleResources.of(context);

    final items = List<FilterChipItem>.empty(growable: true);
    if (episodeFilter.downloadedOnly) {
      final item = FilterChipItem(
          text: localization.downloadedEpisodesFilterOption,
          action: onResetDownloadedOnly);
      items.add(item);
    }

    if (episodeFilter.unplayedOnly) {
      final item = FilterChipItem(
          text: localization.unplayedEpisodesFilterOption,
          action: onResetUnplayedOnly);
      items.add(item);
    }

    if (episodeFilter.sortOrder == PodcastEpisodeDateSortOrder.oldestToNewest) {
      final item = FilterChipItem(
          text: localization.oldestToNewestSortOption,
          action: onResetSortOrder);
      items.add(item);
    }

    return items;
  }
}
