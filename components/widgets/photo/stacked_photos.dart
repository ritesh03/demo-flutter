import 'dart:math';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'photo.dart';

class StackedPhotosWidget extends StatelessWidget {
  final List<String?> photoPaths;
  final PhotoKind photoKind;
  final double size;
  final Color? backgroundColor;
  final double? borderSize;
  final Color? borderColor;
  final int? maxPhotos;
  final TextStyle textStyle;
  final double? visibleSizeFactor;

  const StackedPhotosWidget(
    this.photoKind, {
    Key? key,
    required this.photoPaths,
    required this.size,
    this.backgroundColor,
    this.borderSize,
    this.borderColor,
    this.maxPhotos,
    required this.textStyle,
    this.visibleSizeFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        this.backgroundColor ?? DynamicTheme.get(context).black();
    final borderColor =
        this.borderColor ?? DynamicTheme.get(context).neutral80();
    final borderSize = this.borderSize ?? size * 0.05;
    final maxPhotos = this.maxPhotos ?? 2;
    final visibleSizeFactor = this.visibleSizeFactor ?? size * 0.6;

    final List<Widget> widgets = [];
    for (int index = 0; index < min(photoPaths.length, maxPhotos); index++) {
      final photoPath = photoPaths[index];
      final widget = _StackedWidgetContainer(
        index: index,
        size: size,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderSize: borderSize,
        visibleSizeFactor: visibleSizeFactor,
        child: _StackedPhoto(
          photoPath: photoPath,
          photoKind: photoKind,
          size: size,
        ),
      );
      widgets.add(widget);
    }

    final remainingPhotos = photoPaths.length - maxPhotos;
    if (remainingPhotos > 0) {
      final remainingCountStr =
          (remainingPhotos <= 9) ? "$remainingPhotos" : "9+";
      final widget = _StackedWidgetContainer(
          index: maxPhotos,
          size: size,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderSize: borderSize,
          visibleSizeFactor: visibleSizeFactor,
          child: Center(child: Text(remainingCountStr, style: textStyle)));
      widgets.add(widget);
    }

    return Stack(children: widgets);
  }
}

class _StackedWidgetContainer extends StatelessWidget {
  const _StackedWidgetContainer({
    Key? key,
    required this.index,
    required this.size,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderSize,
    required this.visibleSizeFactor,
    required this.child,
  }) : super(key: key);

  final int index;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final double borderSize;
  final double visibleSizeFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: borderSize),
            borderRadius: BorderRadius.circular(size)),
        margin: EdgeInsets.only(left: visibleSizeFactor * index),
        child: child);
  }
}

class _StackedPhoto extends StatelessWidget {
  const _StackedPhoto({
    Key? key,
    required this.photoPath,
    required this.photoKind,
    required this.size,
  }) : super(key: key);

  final String? photoPath;
  final PhotoKind photoKind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Photo.kind(
      photoPath,
      kind: photoKind,
      options: PhotoOptions(
        width: size,
        height: size,
        shape: BoxShape.circle,
      ),
    );
  }
}
