import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class AccountOption extends StatelessWidget {
  const AccountOption({
    Key? key,
    this.width,
    required this.height,
    required this.margin,
    required this.child,
  }) : super(key: key);

  final double? width;
  final double height;
  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).black(),
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
        child: child);
  }
}
