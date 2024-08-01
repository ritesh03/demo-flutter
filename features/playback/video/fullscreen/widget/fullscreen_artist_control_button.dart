import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class FullScreenArtistControlButton extends StatelessWidget {
  const FullScreenArtistControlButton({
    Key? key,
    required this.notifier,
    required this.onTap,
  }) : super(key: key);

  final ValueNotifier<Artist?> notifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.large.r;
    return ScaleTap(
        onPressed: onTap,
        child: ValueListenableBuilder<Artist?>(
            valueListenable: notifier,
            builder: (_, artist, __) {
              return Photo.artist(
                artist?.thumbnail,
                options: PhotoOptions(
                  width: size,
                  height: size,
                  shape: BoxShape.circle,
                ),
              );
            }));
  }
}
