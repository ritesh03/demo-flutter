import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
    this.size,
    this.strokeWidth,
  }) : super(key: key);

  final double? size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            width: size ?? ComponentSize.small.r,
            height: size ?? ComponentSize.small.r,
            child: CircularProgressIndicator(
                strokeWidth: strokeWidth ?? 4.0,
                color: DynamicTheme.get(context).secondary100())));
  }
}
