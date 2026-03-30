import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/weather_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final WeatherTheme theme;

  const AnimatedBackground({super.key, required this.theme});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;

  @override
  void initState() {
    super.initState();
    _orb1Controller = _createOrbController(seconds: 8);
    _orb2Controller = _createOrbController(seconds: 11);
    _orb3Controller = _createOrbController(seconds: 14);
  }

  AnimationController _createOrbController({required int seconds}) {
    return AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.theme.gradientColors,
        ),
      ),
      child: Stack(
        children: [
          _OrbAnimation(
            controller: _orb1Controller,
            size: size,
            color: widget.theme.accentColor.withOpacity(0.15),
            orbSize: size.width * 0.5,
            leftFn: (t) => size.width * 0.1 + size.width * 0.3 * math.sin(t * math.pi),
            topFn: (t) => size.height * 0.1 + size.height * 0.2 * math.cos(t * math.pi),
            useLeft: true,
            useTop: true,
          ),
          _OrbAnimation(
            controller: _orb2Controller,
            size: size,
            color: widget.theme.gradientColors.first.withOpacity(0.3),
            orbSize: size.width * 0.6,
            leftFn: (t) => size.width * 0.05 + size.width * 0.25 * math.cos(t * math.pi),
            topFn: (t) => size.height * 0.2 + size.height * 0.15 * math.sin(t * math.pi),
            useLeft: false,
            useTop: false,
          ),
          _OrbAnimation(
            controller: _orb3Controller,
            size: size,
            color: widget.theme.accentColor.withOpacity(0.1),
            orbSize: size.width * 0.4,
            leftFn: (t) => size.width * 0.2 + size.width * 0.2 * math.cos(t * math.pi * 1.5),
            topFn: (t) => size.height * 0.05 + size.height * 0.1 * math.sin(t * math.pi),
            useLeft: true,
            useTop: false,
          ),
        ],
      ),
    );
  }
}

class _OrbAnimation extends StatelessWidget {
  final AnimationController controller;
  final Size size;
  final Color color;
  final double orbSize;
  final double Function(double t) leftFn;
  final double Function(double t) topFn;
  final bool useLeft;
  final bool useTop;

  const _OrbAnimation({
    required this.controller,
    required this.size,
    required this.color,
    required this.orbSize,
    required this.leftFn,
    required this.topFn,
    required this.useLeft,
    required this.useTop,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final leftVal = leftFn(t);
        final topVal = topFn(t);

        return Positioned(
          left: useLeft ? leftVal : null,
          right: useLeft ? null : leftVal,
          top: useTop ? topVal : null,
          bottom: useTop ? null : topVal,
          child: _Orb(size: orbSize, color: color),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}