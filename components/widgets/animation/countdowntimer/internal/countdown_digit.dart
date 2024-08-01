import 'package:flutter/material.dart'  hide SearchBar;

import 'countdown_slide_direction.dart';

class CountdownDigit extends StatefulWidget {
  const CountdownDigit({
    Key? key,
    required this.width,
    required this.height,
    required this.animationDuration,
    this.curve = Curves.easeOut,
    this.initValue = 0,
    required this.direction,
    required this.notifier,
    required this.textStyle,
  }) : super(key: key);

  final double width;
  final double height;
  final Duration animationDuration;
  final Curve curve;
  final int initValue;
  final CountdownSlideDirection direction;
  final ValueNotifier<int> notifier;
  final TextStyle textStyle;

  @override
  State<CountdownDigit> createState() => _CountdownDigitState();
}

class _CountdownDigitState extends State<CountdownDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimationOne;
  late Animation<Offset> _offsetAnimationTwo;
  int currentValue = 0;
  int nextValue = 0;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    disposed = false;
    _animationController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _offsetAnimationOne = Tween<Offset>(
      begin: const Offset(0.0, -1.05),
      end: const Offset(0.0, 0.0),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve));

    _offsetAnimationTwo = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 1.05),
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve)
      ..addStatusListener((status) {
        if (widget.direction == CountdownSlideDirection.none) return;
        if (status == AnimationStatus.completed) {
          _animationController.reset();
        }
      }));

    if (!disposed) {
      widget.notifier.addListener(() {
        if (widget.direction == CountdownSlideDirection.none) return;
        if (!_animationController.isCompleted) {
          if (mounted) {
            _animationController.forward();
          }
        }
      });
    }
  }

  void _digit(int value) {
    if (currentValue != value) {
      nextValue = value;
      if (value < 9) {
        currentValue = value + 1;
      } else {
        currentValue = 0;
      }
    } else {
      currentValue = value;
      if (nextValue == 0) {
        currentValue = 1;
      }
    }

    if (_animationController.isDismissed) {
      currentValue = nextValue;
    }
  }

  @override
  void dispose() {
    disposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ValueListenableBuilder(
        valueListenable: widget.notifier,
        builder: (BuildContext context, int value, Widget? child) {
          if (widget.direction == CountdownSlideDirection.none) {
            return AnimatedSwitcher(
              duration: widget.animationDuration,
              switchInCurve: widget.curve,
              switchOutCurve: widget.curve,
              transitionBuilder: (childSwitcher, animation) => FadeTransition(
                opacity: animation,
                child: childSwitcher,
              ),
              child: Text(
                digit(value),
                key: ValueKey(value),
                style: widget.textStyle,
              ),
            );
          } else {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, textWidget) {
                _digit(value);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    FractionalTranslation(
                      translation:
                          widget.direction == CountdownSlideDirection.down
                              ? _offsetAnimationOne.value
                              : -_offsetAnimationOne.value,
                      child: Text(
                        digit(nextValue),
                        style: widget.textStyle,
                      ),
                    ),
                    FractionalTranslation(
                      translation:
                          widget.direction == CountdownSlideDirection.down
                              ? _offsetAnimationTwo.value
                              : -_offsetAnimationTwo.value,
                      child: Text(
                        digit(currentValue),
                        style: widget.textStyle,
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  String digit(int value) => '$value';
}
