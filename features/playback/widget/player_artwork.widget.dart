import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:kwotmusic/util/playback_kind.ext.dart';
import 'package:kwotmusic/util/tuple_value_notifier.dart';

class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return Tuple2ValueListenableBuilder<PlaybackKind?, String?>(
        valueListenable: audioPlayerManager.artworkNotifier,
        builder: (_, tuple, __) {
          final playbackKind = tuple.item1;
          final artwork = tuple.item2;
          if (playbackKind == null) {
            return SizedBox(width: size, height: size);
          }

          return Photo.kind(artwork,
              kind: playbackKind.photoKind,
              options: PhotoOptions(
                  width: size,
                  height: size,
                  borderRadius:
                      BorderRadius.circular(ComponentRadius.normal.r)));
        });
  }
}
