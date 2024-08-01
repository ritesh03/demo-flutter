import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/util/util.dart';

class ForegroundGradientPhoto extends StatelessWidget {
  const ForegroundGradientPhoto({
    Key? key,
    this.width,
    required this.height,
    this.startColor,
    this.startColorShift,
    this.endColor,
    this.endColorShift,
    this.begin,
    this.end,
    this.photoAlignment,
    required this.photoPath,
  }) : super(key: key);

  final double? width;
  final double height;
  final Color? startColor;
  final double? startColorShift;
  final Color? endColor;
  final double? endColorShift;
  final Alignment? begin;
  final Alignment? end;
  final Alignment? photoAlignment;
  final String photoPath;

  @override
  Widget build(BuildContext context) {
    final startColor =
        this.startColor ?? DynamicTheme.get(context).background();
    final endColor = this.endColor ?? startColor.withOpacity(0);

    final width = this.width ?? MediaQuery.of(context).size.width;
    final height = this.height.roundToEven;

    return Container(
      width: width,
      height: height.roundToDouble() + 1,
      alignment: photoAlignment ?? Alignment.bottomCenter,
      foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
              begin: begin ?? Alignment.topCenter,
              end: end ?? Alignment.bottomCenter,
              colors: [startColor, endColor],
              stops: [startColorShift ?? 0, endColorShift ?? 1])),
      child: Photo(
        photoPath,
        options: PhotoOptions(height: height, width: width),
      ),
    );
  }
}
