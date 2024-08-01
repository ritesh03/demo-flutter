import 'dart:ui';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'photo.dart';

class BlurredCoverPhoto extends StatelessWidget {
  const BlurredCoverPhoto({
    Key? key,
    required this.photoPath,
    required this.photoKind,
    required this.height,
  }) : super(key: key);

  final String? photoPath;
  final PhotoKind photoKind;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.r),
                bottomRight: Radius.circular(ComponentRadius.normal.r))),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          _buildPhotoBlur(context),
          _buildPhotoVignette(context),
        ]));
  }

  Widget _buildPhotoBlur(BuildContext context) {
    final photoPath = this.photoPath;
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ComponentRadius.normal.r),
                bottomRight: Radius.circular(ComponentRadius.normal.r))),
        clipBehavior: Clip.antiAlias,
        child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Photo.kind(
              photoPath,
              kind: photoKind,
              options: PhotoOptions(
                fit: BoxFit.cover,
                height: height,
              ),
            )));
  }

  Widget _buildPhotoVignette(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: RadialGradient(colors: const [
          Colors.transparent,
          Colors.black54,
          Colors.black54,
          Colors.transparent,
        ], radius: 4.r)));
  }
}
