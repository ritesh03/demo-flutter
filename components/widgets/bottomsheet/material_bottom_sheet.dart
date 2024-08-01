import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showMaterialBottomSheet<T>(
  BuildContext context, {
  Color? backgroundColor,
  BorderRadius? borderRadius,
  required ScrollableWidgetBuilder builder,
  bool expand = true,
  EdgeInsets? margin,
}) {
//=
  return showMaterialModalBottomSheet<T>(
      backgroundColor: Colors.transparent,
      barrierColor: DynamicTheme.get(context).black().withOpacity(0.9),
      builder: (context) => MaterialBottomSheet(
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          builder: builder,
          margin: margin),
      context: context,
      expand: expand,
      useRootNavigator: true);
}

class MaterialBottomSheet extends StatelessWidget {
  const MaterialBottomSheet({
    Key? key,
    this.backgroundColor,
    this.borderRadius,
    required this.builder,
    this.margin,
  }) : super(key: key);

  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final ScrollableWidgetBuilder builder;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        this.backgroundColor ?? DynamicTheme.get(context).neutral80();

    final borderRadius = this.borderRadius ??
        BorderRadius.only(
            topLeft: Radius.circular(ComponentRadius.normal.r),
            topRight: Radius.circular(ComponentRadius.normal.r));

    final controller = ModalScrollController.of(context)!;

    return SafeArea(
        child: Container(
            margin: margin ?? EdgeInsets.only(top: ComponentInset.normal.h),
            decoration: BoxDecoration(
                color: backgroundColor, borderRadius: borderRadius),
            clipBehavior: Clip.antiAlias,
            child: builder(context, controller)));
  }
}
