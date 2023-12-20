import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/helpers/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Heart extends SpriteAnimationComponent with HasGameReference<PixelAdventure> {
  Heart({
    super.position,
    super.size,
    super.priority = -1,
  });

  final _stepTime = 0.1;

  final hitbox = const CustomHitbox.rectangle(offsetX: 3, offsetY: 4, width: 14, height: 13);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    animation = _spriteAnimation(8);
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
      game.images.fromCache(collected ? 'Items/Fruits/Collected.png' : 'Items/Fruits/Heart.png'),
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
    game.player.health++;
    await animationTicker?.completed;
    removeFromParent();
  }
}
