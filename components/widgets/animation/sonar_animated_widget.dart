import 'package:flutter/material.dart'  hide SearchBar;

class Sonar extends StatefulWidget {
  const Sonar({
    Key? key,
    required this.duration,
    required this.size,
    required this.waveColor,
    required this.waveStrokeWidth,
    required this.child,
  }) : super(key: key);

  final Duration duration;
  final double size;
  final Color waveColor;
  final double waveStrokeWidth;
  final Widget child;

  @override
  State<Sonar> createState() => _SonarState();
}

class _SonarState extends State<Sonar> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(() {
      setState(() {});
    });

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        child: CustomPaint(
            painter: _WavePainter(_controller,
                waveColor: widget.waveColor,
                waveStrokeWidth: widget.waveStrokeWidth,
                endRadius: widget.size / 2),
            child: widget.child));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WavePainter extends CustomPainter {
  final double beginRadius;
  final double endRadius;
  final double beginOpacity;
  final double endOpacity;

  final Animation radiusAnimation;
  final Animation opacityAnimation;
  final Color waveColor;
  final double waveStrokeWidth;

  _WavePainter(
    AnimationController controller, {
    required this.waveColor,
    required this.waveStrokeWidth,
    this.beginRadius = 0.0,
    required this.endRadius,
    this.beginOpacity = 1.0,
    this.endOpacity = 0.0,
  })  : radiusAnimation =
            Tween(begin: beginRadius, end: endRadius).animate(controller),
        opacityAnimation =
            Tween(begin: beginOpacity, end: endOpacity).animate(controller);

  @override
  void paint(Canvas canvas, Size size) {
    _drawFirstWave(canvas, size, radiusAnimation, opacityAnimation);
    _drawSecondWave(canvas, size, radiusAnimation, opacityAnimation);
  }

  void _drawFirstWave(
    Canvas canvas,
    Size size,
    Animation radiusAnimation,
    Animation opacityAnimation,
  ) {
    double waveRadius = radiusAnimation.value;
    double waveOpacity = opacityAnimation.value;
    canvas.drawCircle(
      Offset(size.width / 2.0, size.height / 2.0),
      waveRadius,
      Paint()
        ..color = waveColor.withOpacity(waveOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = waveStrokeWidth,
    );
  }

  void _drawSecondWave(
    Canvas canvas,
    Size size,
    Animation radiusAnimation,
    Animation opacityAnimation,
  ) {
    double waveRadius = radiusAnimation.value + (endRadius / 2).ceil();
    if (waveRadius >= endRadius) {
      waveRadius = waveRadius - endRadius;
    }

    double maxOpacity = 1;
    double opacity = opacityAnimation.value * maxOpacity;
    double waveOpacity = opacity + 0.01 + maxOpacity / 2;
    if (waveOpacity >= maxOpacity) {
      waveOpacity = waveOpacity - maxOpacity;
    }

    canvas.drawCircle(
      Offset(size.width / 2.0, size.height / 2.0),
      waveRadius,
      Paint()
        ..color = waveColor.withOpacity(waveOpacity / maxOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = waveStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
