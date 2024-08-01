import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IndexedPageIndicator extends StatelessWidget {
  const IndexedPageIndicator({
    Key? key,
    required this.count,
    required this.onPressed,
    required this.selectedIndex,
    required this.size,
  }) : super(key: key);

  final int count;
  final Function(int index) onPressed;
  final int selectedIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSmoothIndicator(
      activeIndex: selectedIndex,
      count: count,
      effect: WormEffect(
        dotWidth: size,
        dotHeight: size,
        dotColor: DynamicTheme.get(context).black(),
        activeDotColor: DynamicTheme.get(context).secondary100(),
      ),
      onDotClicked: onPressed,
    );
  }
}
