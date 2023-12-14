import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum FruitType {
  unknown(),
  apple(value: 1),
  bananas(filename: 'Bananas', value: 2),
  cherries(filename: 'Cherries', value: 3),
  kiwi(filename: 'Kiwi', value: 4),
  melon(filename: 'Melon', value: 5),
  orange(filename: 'Orange', value: 6),
  pineapple(filename: 'Pineapple', value: 9),
  strawberry(filename: 'Strawberry', value: 10);

  final String filename;
  final int value;
  const FruitType({this.filename = 'Apple', this.value = 0});

  static FruitType fromFilename(String filename) {
    switch (filename) {
      case 'Apple':
        return FruitType.apple;
      case 'Bananas':
        return FruitType.bananas;
      case 'Cherries':
        return FruitType.cherries;
      case 'Kiwi':
        return FruitType.kiwi;
      case 'Melon':
        return FruitType.melon;
      case 'Orange':
        return FruitType.orange;
      case 'Pineapple':
        return FruitType.pineapple;
      case 'Strawberry':
        return FruitType.strawberry;
      default:
        return FruitType.unknown;
    }
  }
}

class Fruit extends SpriteAnimationComponent with HasGameReference<PixelAdventure> {
  final FruitType fruit;
  Fruit({
    super.position,
    super.size,
    super.priority = -1,
    this.fruit = FruitType.apple,
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
      game.images.fromCache(collected ? 'Items/Fruits/Collected.png' : 'Items/Fruits/${fruit.filename}.png'),
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
    game.player.fruitsPoints += game.level.fruits.firstWhere((Fruit fruit) => fruit == this).fruit.value;
    await animationTicker?.completed;
    removeFromParent();
    game.level.fruits.removeWhere((fruit) => fruit == this);
  }
}
