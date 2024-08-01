import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotmusic/components/kit/kit.dart';

class PageTitleBarText extends StatelessWidget {
  const PageTitleBarText({
    Key? key,
    required this.text,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: onTap,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldHeading5.copyWith(color: color)),
    );
  }
}
