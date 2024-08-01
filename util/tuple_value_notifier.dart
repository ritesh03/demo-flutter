import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:tuple/tuple.dart';

class Tuple2ValueListenableBuilder<X, Y> extends StatelessWidget {
  //=
  const Tuple2ValueListenableBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
  }) : super(key: key);

  final ValueListenable<Tuple2<X, Y>> valueListenable;
  final ValueWidgetBuilder<Tuple2<X, Y>> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Tuple2<X, Y>>(
      valueListenable: valueListenable,
      builder: builder,
    );
  }
}

class Tuple3ValueListenableBuilder<X, Y, Z> extends StatelessWidget {
  //=
  const Tuple3ValueListenableBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
  }) : super(key: key);

  final ValueListenable<Tuple3<X, Y, Z>> valueListenable;
  final Tuple3ValueWidgetBuilder<X, Y, Z> builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Tuple3<X, Y, Z>>(
        key: key,
        valueListenable: valueListenable,
        builder: (context, tuple, child) {
          return builder(context, tuple.item1, tuple.item2, tuple.item3, child);
        });
  }
}

typedef Tuple3ValueWidgetBuilder<X, Y, Z> = Widget Function(
  BuildContext context,
  X item1,
  Y item2,
  Z item3,
  Widget? child,
);
