import 'package:flutter/material.dart'  hide SearchBar;

import 'photo_source.dart';

class PhotoOptions {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final PhotoSource? photoSource;
  final BoxShape shape;
  final Widget? placeholder;

  const PhotoOptions({
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.photoSource,
    this.shape = BoxShape.rectangle,
    this.placeholder,
  });

  int? obtainCacheSize(double devicePixelRatio) {
    final double? givenSize = width ?? height;
    if (givenSize != null) {
      return (givenSize * devicePixelRatio).round();
    }

    return null;
  }

  PhotoOptions copyWith({
    double? width,
    double? height,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    BoxFit? fit,
    PhotoSource? photoSource,
    BoxShape? shape,
    Widget? placeholder,
  }) {
    return PhotoOptions(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fit: fit ?? this.fit,
      photoSource: photoSource ?? this.photoSource,
      shape: shape ?? this.shape,
      placeholder: placeholder ?? this.placeholder,
    );
  }
}
