import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/overlays/heart.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Hud extends PositionComponent with HasGameRef<PixelAdventure> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  late TextComponent _scoreTextComponent;

  @override
  Future<void> onLoad() async {
    _scoreTextComponent = TextComponent(
      text: '${game.player.fruitsCollected}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 10,
          fontFamily: 'PressStart2P',
          color: Color.fromRGBO(187, 170, 13, 1),
        ),
      ),
      anchor: Anchor.centerRight,
      position: Vector2(game.size.x - 35, 20),
    );
    add(_scoreTextComponent);

    final fruitSprite = await game.loadSprite('Items/Fruits/Melon.png', srcSize: Vector2.all(32));
    add(
      SpriteComponent(
        sprite: fruitSprite,
        position: Vector2(game.size.x - 20, 20),
        size: Vector2.all(32),
        anchor: Anchor.center,
      ),
    );

    for (var i = 1; i <= game.player.health; i++) {
      final positionX = 15 * i;
      await add(
        HeartHealthComponent(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), 10),
          size: Vector2.all(20),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.player.fruitsCollected}';
  }
}
