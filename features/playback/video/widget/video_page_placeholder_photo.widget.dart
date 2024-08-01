import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class VideoPagePlaceholderPhoto extends StatelessWidget {
  const VideoPagePlaceholderPhoto({
    Key? key,
    this.notifier,
    this.thumbnail,
    required this.photoKind,
    this.borderRadius,
  }) : super(key: key);

  final ValueNotifier<String?>? notifier;
  final String? thumbnail;
  final PhotoKind photoKind;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final notifier = this.notifier;
    if (notifier != null) {
      return ValueListenableBuilder<String?>(
          valueListenable: notifier,
          builder: (context, thumbnail, __) {
            return Photo.kind(
              thumbnail,
              kind: photoKind,
              options: PhotoOptions(borderRadius: borderRadius),
            );
          });
    }

    return Photo.kind(
      thumbnail,
      kind: photoKind,
      options: PhotoOptions(borderRadius: borderRadius),
    );
  }
}
