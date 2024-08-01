import 'package:flutter/material.dart'  hide SearchBar;

class ReorderableUtil {
  static Transform buildDragFeedback(
    BuildContext context,
    BoxConstraints constraints,
    Widget child,
  ) {
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
          child: ConstrainedBox(constraints: constraints, child: child),
          elevation: 0.0,
          color: Colors.transparent),
    );
  }
}
