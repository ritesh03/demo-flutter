import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';

class PodcastsFilterLayout extends StatelessWidget {
  const PodcastsFilterLayout({
    Key? key,
    required this.categories,
    required this.onRemoveTap,
    this.margin,
  }) : super(key: key);

  final List<PodcastCategory> categories;
  final Function(PodcastCategory category) onRemoveTap;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FilterChipLayout(
      items: categories.map(_categoryToChipItem).toList(),
      margin: margin,
    );
  }

  FilterChipItem _categoryToChipItem(PodcastCategory category) {
    return FilterChipItem(
      text: category.title,
      action: () => onRemoveTap(category),
    );
  }
}
