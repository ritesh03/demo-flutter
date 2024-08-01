import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

import 'photo_kind.dart';
import 'photo_options.dart';
import 'photo_source.dart';

export 'photo_kind.dart';
export 'photo_options.dart';
export 'photo_source.dart';

// CACHE: https://github.com/flutter/flutter/issues/56239
class Photo extends StatelessWidget {
  const Photo(
    this.path, {
    Key? key,
    this.kind,
    required this.options,
  }) : super(key: key);

  const Photo.kind(
    String? path, {
    Key? key,
    required PhotoKind kind,
    required PhotoOptions options,
  }) : this(path, key: key, kind: kind, options: options);

  const Photo.album(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.album, options: options);

  const Photo.any(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.any, options: options);

  const Photo.artist(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.artist, options: options);

  const Photo.country(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.country, options: options);

  const Photo.playlist(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.playlist, options: options);

  const Photo.podcast(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.podcast, options: options);

  const Photo.podcastCategory(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.podcastCategory, options: options);

  const Photo.podcastEpisode(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.podcastEpisode, options: options);

  const Photo.profileCover(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.profileCover, options: options);

  const Photo.radioStation(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.radioStation, options: options);

  const Photo.show(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.show, options: options);

  const Photo.skit(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.skit, options: options);

  const Photo.track(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.track, options: options);

  const Photo.user(
    String? path, {
    Key? key,
    required PhotoOptions options,
  }) : this(path, key: key, kind: PhotoKind.user, options: options);

  final String? path;
  final PhotoKind? kind;
  final PhotoOptions options;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: options.width,
        height: options.height,
        decoration: BoxDecoration(
          shape: options.shape,
          borderRadius: options.borderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildChild());
  }

  Widget _buildChild() {
    final path = this.path;
    if (path == null) {
      return _PlaceholderPhoto(kind: kind, options: options);
    }

    PhotoSource? photoSource = options.photoSource;
    if (photoSource == null) {
      // TODO: Use URI-validation checks
      if (path.startsWith("http")) {
        photoSource = PhotoSource.network;
      } else if (path.startsWith("assets")) {
        photoSource = PhotoSource.asset;
      } else {
        photoSource = PhotoSource.file;
      }
    }

    switch (photoSource) {
      case PhotoSource.asset:
        return _AssetPhoto(path, options: options);
      case PhotoSource.file:
        return _FilePhoto(File(path), options: options);
      case PhotoSource.network:
        return _NetworkPhoto(path, kind: kind, options: options);
    }
  }
}

class _AssetPhoto extends StatelessWidget {
  const _AssetPhoto(
    this.path, {
    Key? key,
    required this.options,
  }) : super(key: key);

  final String path;
  final PhotoOptions options;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Image.asset(path,
        width: options.width,
        height: options.height,
        cacheWidth: options.obtainCacheSize(devicePixelRatio),
        fit: options.fit);
  }
}

class _FilePhoto extends StatelessWidget {
  const _FilePhoto(
    this.file, {
    Key? key,
    required this.options,
  }) : super(key: key);

  final File file;
  final PhotoOptions options;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Image.file(file,
        width: options.width,
        height: options.height,
        cacheWidth: options.obtainCacheSize(devicePixelRatio),
        fit: options.fit,
        errorBuilder: (_, __, ___) => _PlaceholderPhoto(options: options));
  }
}

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto(
    this.path, {
    Key? key,
    required this.kind,
    required this.options,
  }) : super(key: key);

  final String path;
  final PhotoKind? kind;
  final PhotoOptions options;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return CachedNetworkImage(
        width: options.width,
        height: options.height,
        memCacheWidth: options.obtainCacheSize(devicePixelRatio),
        imageUrl: path,
        fit: options.fit,
        placeholder: (_, __) => _PlaceholderPhoto(kind: kind, options: options),
        errorWidget: (_, __, ___) =>
            _PlaceholderPhoto(kind: kind, options: options));
  }
}

class _PlaceholderPhoto extends StatelessWidget {
  const _PlaceholderPhoto({
    Key? key,
    this.kind,
    required this.options,
  }) : super(key: key);

  final PhotoKind? kind;
  final PhotoOptions options;

  @override
  Widget build(BuildContext context) {
    final placeholder = options.placeholder;
    if (placeholder != null) {
      return placeholder;
    }

    final kind = this.kind;
    if (kind != null && kind != PhotoKind.country) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final cacheSize = options.obtainCacheSize(devicePixelRatio);

      return Container(
          color: DynamicTheme.get(context).neutral10(),
          child: Image.asset(
            kind.placeholderAssetPath,
            width: options.width,
            height: options.height,

            // Assume placeholders to be square in shape
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
            fit: BoxFit.contain,
          ));
    }

    return Container(
      decoration: BoxDecoration(
        color: DynamicTheme.get(context).neutral10(),
        shape: options.shape,
        borderRadius: options.borderRadius,
      ),
    );
  }
}
