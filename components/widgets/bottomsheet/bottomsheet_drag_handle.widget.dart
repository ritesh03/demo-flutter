import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class BottomSheetDragHandle extends StatelessWidget {
  const BottomSheetDragHandle({
    Key? key,
    this.width,
    this.height,
    this.margin,
  }) : super(key: key);

  final double? width;
  final double? height;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? ComponentSize.normal.w;
    final height = this.height ?? 4.r;
    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.symmetric(vertical: ComponentInset.small.h),
      decoration: BoxDecoration(
          color: DynamicTheme.get(context).background(),
          borderRadius: BorderRadius.circular(width)),
    );
  }
}
