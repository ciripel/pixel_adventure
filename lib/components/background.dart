import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Background extends ParallaxComponent<PixelAdventure> {
  final String type;

  Background({
    super.size,
    super.position,
    super.priority = -10,
    this.type = 'Super Mountain Dusk',
  });

  @override
  FutureOr<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('Background/$type/sky.png'),
        ParallaxImageData('Background/$type/far-clouds.png'),
        ParallaxImageData('Background/$type/near-clouds.png'),
        ParallaxImageData('Background/$type/far-mountains.png'),
        ParallaxImageData('Background/$type/mountains.png'),
        ParallaxImageData('Background/$type/trees.png'),
      ],
      velocityMultiplierDelta: Vector2(1.15, 0),
    );
    return super.onLoad();
  }
}
