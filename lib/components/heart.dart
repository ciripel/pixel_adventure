import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/constants/constants.dart';
import 'package:pixel_adventure/helpers/custom_shape.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Heart extends SpriteAnimationComponent with HasGameReference<PixelAdventure> {
  Heart({
    super.position,
    super.size,
    super.priority = -1,
  });

  final _stepTime = 0.1;

  final hitbox = const CustomShape.rectangle(left: 3, top: 4, width: 14, height: 13);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    animation = _spriteAnimation(6);
    add(
      RectangleHitbox(
        position: Vector2(hitbox.left, hitbox.top),
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
    if (game.playSoundEffects) {
      AudioPlayer().play(AssetSource('audio/pickup_fruit.wav'), volume: game.soundEffectsVolume);
    }
    animation = _spriteAnimation(6, collected: true);
    if (game.player.health < Constants.maxPlayerLives) game.player.health++;
    await animationTicker?.completed;
    removeFromParent();
  }
}
