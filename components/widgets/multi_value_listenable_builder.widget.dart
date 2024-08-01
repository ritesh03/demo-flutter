import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'  hide SearchBar;

class TwoValuesListenableBuilder<A, B> extends StatelessWidget {
  const TwoValuesListenableBuilder({
    Key? key,
    required this.valueListenable1,
    required this.valueListenable2,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> valueListenable1;
  final ValueListenable<B> valueListenable2;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
        valueListenable: valueListenable1,
        builder: (_, value1, __) {
          return ValueListenableBuilder<B>(
              valueListenable: valueListenable2,
              builder: (context, value2, __) {
                return builder(context, value1, value2, child);
              });
        });
  }
}
