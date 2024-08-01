import 'package:boxy/boxy.dart';
import 'package:flutter/material.dart'  hide SearchBar;

class DependantHeightAdjustment extends StatelessWidget {
  const DependantHeightAdjustment({
    Key? key,
    required this.source,
    required this.target,
    required this.targetWidth,
  }) : super(key: key);

  final Widget source;
  final Widget target;
  final double targetWidth;

  @override
  Widget build(BuildContext context) {
    return CustomBoxy(
        delegate: _HeightAdjustmentDelegate(targetWidth: targetWidth),
        children: [
          BoxyId(id: #source, child: source),
          BoxyId(id: #target, child: target)
        ]);
  }
}

class _HeightAdjustmentDelegate extends BoxyDelegate {
  _HeightAdjustmentDelegate({required this.targetWidth});

  final double targetWidth;

  @override
  Size layout() {
    final source = getChild(#source);
    final sourceSize = source.layout(constraints);
    source.position(Offset.zero);
    source.ignore();

    final target = getChild(#target);
    target.layoutRect(Rect.fromLTRB(0, 0, targetWidth, sourceSize.height));
    target.position(Offset.zero);

    return Size(targetWidth, sourceSize.height);
  }

  @override
  bool shouldRelayout(_HeightAdjustmentDelegate delegate) => false;
}