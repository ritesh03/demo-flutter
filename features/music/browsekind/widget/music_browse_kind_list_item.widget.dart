import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class MusicBrowseKindListItem extends StatelessWidget {
  const MusicBrowseKindListItem({
    Key? key,
    required this.kind,
    required this.onTap,
  }) : super(key: key);

  final MusicBrowseKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = 48.h;
    return ScaleTap(
      onPressed: onTap,
      child: Container(
          height: itemHeight,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _buildThumbnail(size: itemHeight),
            Expanded(child: _buildTitle()),
          ])),
    );
  }

  Widget _buildThumbnail({required double size}) {
    return Photo.any(
      kind.images.isEmpty ? null : kind.images.first,
      options: PhotoOptions(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        child: Text(kind.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.boldBody));
  }
}
