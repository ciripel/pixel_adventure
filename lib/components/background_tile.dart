import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;

  BackgroundTile({
    super.position,
    super.priority = -10,
    this.color = 'Gray',
  });

  final double scrollSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(0, -scrollSpeed),
      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
    );
    return super.onLoad();
  }
}
