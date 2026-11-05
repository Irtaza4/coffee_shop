import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/coffee.dart';

class CoffeeCup extends StatelessWidget {
  const CoffeeCup({
    super.key,
    required this.coffee,
    this.angle = 0,
    this.heroTag,
  });
  final Coffee coffee;
  final double angle;
  final String? heroTag;

  // Hue rotation preserves the lighting and detail of the shared product asset.
  static List<double> _hue(double degrees) {
    final c = math.cos(degrees * math.pi / 180),
        s = math.sin(degrees * math.pi / 180);
    return [
      .213 + c * .787 - s * .213,
      .715 - c * .715 - s * .715,
      .072 - c * .072 + s * .928,
      0,
      0,
      .213 - c * .213 + s * .143,
      .715 + c * .285 + s * .140,
      .072 - c * .072 - s * .283,
      0,
      0,
      .213 - c * .213 - s * .787,
      .715 - c * .715 + s * .715,
      .072 + c * .928 + s * .072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget cup = Transform.rotate(
      angle: angle,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_hue(coffee.hue)),
        child: Image.asset(
          'assets/images/coffee-cup.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
    if (heroTag != null) cup = Hero(tag: heroTag!, child: cup);
    return ExcludeSemantics(child: cup);
  }
}
