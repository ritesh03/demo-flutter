import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class Separator extends StatelessWidget {
  const Separator({Key? key, this.height, this.color}) : super(key: key);

  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final height = this.height ?? 2.h;

    return Container(
        height: height,
        decoration: BoxDecoration(
            color: color ?? DynamicTheme.get(context).black(),
            borderRadius: BorderRadius.circular(height)));
  }
}
