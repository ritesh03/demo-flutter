import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class Glow extends StatelessWidget {
  const Glow({
    Key? key,
    this.color,
    this.blurRadius,
    this.spreadRadius,
  }) : super(key: key);

  final Color? color;
  final double? blurRadius;
  final double? spreadRadius;

  @override
  Widget build(BuildContext context) {
    final glowColor = color ?? DynamicTheme.get(context).secondary100();
    final blurRadius = this.blurRadius ?? 100.r;
    final spreadRadius = this.spreadRadius ?? 48.h;

    return Center(
        child: Container(
            height: 0,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  blurRadius: blurRadius,
                  blurStyle: BlurStyle.normal,
                  color: glowColor.withOpacity(0.6),
                  spreadRadius: spreadRadius)
            ])));
  }
}
