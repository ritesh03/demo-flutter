import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class BasicSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topInsetPadding;
  final double toolbarHeight;
  final double expandedHeight;
  final Widget title;
  final double horizontalTitlePadding;
  final Widget topBar;

  BasicSliverHeaderDelegate(
    BuildContext context, {
    required this.toolbarHeight,
    required this.expandedHeight,
    required this.title,
    required this.horizontalTitlePadding,
    required this.topBar,
  }) : topInsetPadding = MediaQuery.of(context).padding.top;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkPercent = (shrinkOffset / expandedHeight).clamp(0.0, 1.0);
    return Container(
        decoration: BoxDecoration(
          color: DynamicTheme.get(context).black().withOpacity(shrinkPercent),
          //boxShadow: obtainShadow(context, shrinkPercent),
        ),
        padding: EdgeInsets.only(top: topInsetPadding),
        child: Stack(children: [
          SizedBox(height: toolbarHeight, child: topBar),
          _buildTitle(shrinkPercent),
        ]));
  }

  @override
  double get maxExtent => topInsetPadding + expandedHeight;

  @override
  double get minExtent => topInsetPadding + toolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  Widget _buildTitle(double shrinkPercent) {
    final titlePadding = horizontalTitlePadding +
        (toolbarHeight - horizontalTitlePadding) * shrinkPercent;

    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
          height: toolbarHeight,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: titlePadding),
          child: title),
    ]);
  }

  List<BoxShadow> obtainShadow(BuildContext context, double shrinkPercent) {
    return [
      BoxShadow(
        color: DynamicTheme.get(context).black(),
        blurRadius: 20 * shrinkPercent,
        spreadRadius: 2.r * shrinkPercent,
      )
    ];
  }
}
