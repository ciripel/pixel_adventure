import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameReference<PixelAdventure> {
  final String fruit;
  Fruit({
    super.position,
    super.size,
    super.priority = -1,
    this.fruit = 'Apple',
  });

  final _stepTime = 0.05;

  final hitbox = const CustomHitbox.rectangle(offsetX: 10, offsetY: 10, width: 12, height: 12);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    animation = _spriteAnimation(17);
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
        isSolid: true,
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

  void collidedWithPlayer() async {
    if (game.playSoundEffects) FlameAudio.play('pickup_fruit.wav');
    animation = _spriteAnimation(6, collected: true);
    game.player.fruitsCollected++;
    await animationTicker?.completed;
    removeFromParent();
    game.level.fruits.removeWhere((element) => element == this);
  }
}
