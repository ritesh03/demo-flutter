import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/filter/filter_chip_layout.widget.dart';

class PlaylistsAppliedFiltersWidget extends StatelessWidget {
  const PlaylistsAppliedFiltersWidget({
    Key? key,
    required this.genres,
    required this.onRemoveTap,
    this.margin,
  }) : super(key: key);

  final List<MusicGenre> genres;
  final Function(MusicGenre) onRemoveTap;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return FilterChipLayout(
      items: genres.map(_genreToChipItem).toList(),
      margin: margin,
    );
  }

  FilterChipItem _genreToChipItem(MusicGenre genre) {
    return FilterChipItem(
      text: genre.title,
      action: () => onRemoveTap(genre),
    );
  }
}
