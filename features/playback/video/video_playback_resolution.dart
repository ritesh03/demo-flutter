import 'package:flutter/material.dart'  hide SearchBar;

class VideoPlaybackResolution {
  VideoPlaybackResolution({required this.name, required this.url});

  final String name;
  final String url;
}

typedef VideoPlaybackResolutionsNotifier
    = ValueNotifier<List<VideoPlaybackResolution>>;
