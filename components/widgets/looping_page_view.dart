import 'package:flutter/material.dart'  hide SearchBar;

class LoopingPageView extends StatelessWidget {
  const LoopingPageView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
  }) : super(key: key);

  final LoopingPageController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: controller,
        itemCount: controller.maxItemCount,
        onPageChanged: (pageIndex) {
          return controller.setCurrentItemIndex(pageIndex % itemCount);
        },
        itemBuilder: (context, itemIndex) {
          return itemBuilder(context, itemIndex % itemCount);
        });
  }
}

class LoopingPageController extends PageController {
  LoopingPageController({
    this.maxItemCount = 20000,
    double viewportFraction = 0.8,
  }) : super(
          initialPage: 0,//maxItemCount ~/ 2,
          viewportFraction: viewportFraction,
        );

  final int maxItemCount;

  int _currentItemIndex = 1;

  int get currentItemIndex => _currentItemIndex;

  void setCurrentItemIndex(int itemIndex) {
    _currentItemIndex = itemIndex;
  }
}
