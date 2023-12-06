import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final String fruit;
  Fruit({
    super.position,
    super.size,
    this.fruit = 'Apple',
  });

  final _stepTime = 0.05;

  bool _collected = false;
  final hitbox = const CustomHitbox.rectangle(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    animation = _spriteAnimation(17);
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );
    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(int amount, {bool collected = false}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(collected ? 'Items/Fruits/Collected.png' : 'Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: _stepTime,
        textureSize: Vector2.all(32),
        loop: collected ? false : true,
      ),
    );
  }

  void collidedWithPlayer() {
    if (!_collected) {
      animation = _spriteAnimation(6, collected: true);
      game.player.fruitsCollected++;
      _collected = true;
    }

    Future.delayed(const Duration(milliseconds: 300), removeFromParent);
  }
}
