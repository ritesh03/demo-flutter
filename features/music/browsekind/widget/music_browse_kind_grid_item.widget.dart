import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class MusicBrowseKindGridItem extends StatelessWidget {
  const MusicBrowseKindGridItem({
    Key? key,
    required this.width,
    required this.kind,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double? width;
  final MusicBrowseKind kind;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: onTap,
        child: Container(
            width: width,
            padding: padding,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: _buildThumbnail(context)));
  }

  Widget _buildThumbnail(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Photo.any(
          kind.images.isEmpty ? null : kind.images.first,
          options: PhotoOptions(
              width: width,
              height: width,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              placeholder: _BrowseKindPlaceholder(kind: kind)),
        ));
  }
}

class _BrowseKindPlaceholder extends StatelessWidget {
  const _BrowseKindPlaceholder({
    Key? key,
    required this.kind,
  }) : super(key: key);

  final MusicBrowseKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: DynamicTheme.get(context).black(),
      child: Text(kind.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading4
              .copyWith(color: DynamicTheme.get(context).white()),
          textAlign: TextAlign.center),
    );
  }
}
