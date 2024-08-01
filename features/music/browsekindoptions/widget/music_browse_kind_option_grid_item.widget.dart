import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class MusicBrowseKindOptionGridItem extends StatelessWidget {
  const MusicBrowseKindOptionGridItem({
    Key? key,
    required this.width,
    required this.option,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double? width;
  final MusicBrowseKindOption option;
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
          option.images.isEmpty ? null : option.images.first,
          options: PhotoOptions(
              width: width,
              height: width,
              borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
              placeholder: _BrowseKindOptionPlaceholder(option: option)),
        ));
  }
}

class _BrowseKindOptionPlaceholder extends StatelessWidget {
  const _BrowseKindOptionPlaceholder({
    Key? key,
    required this.option,
  }) : super(key: key);

  final MusicBrowseKindOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: DynamicTheme.get(context).black(),
      child: Text(option.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.heading4
              .copyWith(color: DynamicTheme.get(context).white()),
          textAlign: TextAlign.center),
    );
  }
}
