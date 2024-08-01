import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class ToggleSwitch extends StatefulWidget {
  const ToggleSwitch({
    Key? key,
    this.width,
    this.height,
    required this.checked,
    this.enabled = true,
    required this.onChanged,
  }) : super(key: key);

  final double? width;
  final double? height;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  final duration = const Duration(milliseconds: 200);

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with SingleTickerProviderStateMixin {
  late final Animation _toggleAnimation;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: widget.checked ? 1.0 : 0.0,
      duration: widget.duration,
    );
    _toggleAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checked == widget.checked) return;

    if (widget.checked) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
              onTap: () {
                if (!widget.enabled) return;
                if (widget.checked) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }

                widget.onChanged(!widget.checked);
              },
              child: Container(
                width: obtainWidth(),
                height: obtainHeight(),
                decoration: BoxDecoration(
                  borderRadius: obtainTrackBorderRadius(),
                  color: obtainTrackColor(),
                  border: obtainTrackBorder(),
                ),
                child: Align(
                    alignment: _toggleAnimation.value, child: _buildThumb()),
              ));
        });
  }

  Widget _buildThumb() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
          margin: EdgeInsets.all(obtainThumbMargin()),
          decoration: BoxDecoration(
            color: obtainThumbColor(),
            borderRadius: obtainThumbBorderRadius(),
          )),
    );
  }

  Color obtainThumbColor() {
    if (!widget.enabled) {
      return DynamicTheme.get(context).secondary40();
    }

    if (widget.checked) {
      return DynamicTheme.get(context).white();
    }

    return DynamicTheme.get(context).secondary60();
  }

  BorderRadius obtainThumbBorderRadius() {
    return BorderRadius.circular(ComponentRadius.small.r);
  }

  Color obtainTrackColor() {
    if (!widget.enabled) {
      return Colors.transparent;
    }

    if (widget.checked) {
      return DynamicTheme.get(context).secondary100();
    }

    return Colors.transparent;
  }

  Border obtainTrackBorder() {
    if (!widget.enabled) {
      return Border.all(
          color: DynamicTheme.get(context).secondary40(), width: 2.w);
    }

    if (widget.checked) {
      return Border.all(
          color: DynamicTheme.get(context).secondary100(), width: 2.w);
    }

    return Border.all(
        color: DynamicTheme.get(context).secondary60(), width: 2.w);
  }

  BorderRadius obtainTrackBorderRadius() {
    return BorderRadius.circular(ComponentRadius.normal.r);
  }

  double obtainHeight() {
    return widget.height ?? ComponentSize.normal.h;
  }

  double obtainThumbMargin() {
    return 2.r;
  }

  double obtainThumbSize() {
    return obtainHeight() * 2 / 3;
  }

  double obtainWidth() {
    return widget.width ?? obtainHeight() * 2;
  }
}
