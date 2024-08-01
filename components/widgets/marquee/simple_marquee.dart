import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/widgets/marquee/marquee.dart';

class SimpleMarquee extends StatelessWidget {
  const SimpleMarquee({
    Key? key,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: textStyle,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      pauseAfterRound: const Duration(seconds: 2),
      velocity: 100.0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
