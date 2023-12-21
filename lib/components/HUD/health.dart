import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum HeartState {
  available,
  unavailable,
}

class Health extends SpriteGroupComponent<HeartState> with HasGameReference<PixelAdventure> {
  final int heartNumber;

  Health({
    required this.heartNumber,
    required super.position,
    required super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority = 10,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final availableSprite = await game.loadSprite(
      'HUD/Heart.png',
      srcSize: Vector2.all(32),
    );

    final unavailableSprite = await game.loadSprite(
      'HUD/Heart_empty.png',
      srcSize: Vector2.all(1),
    );

    sprites = {
      HeartState.available: availableSprite,
      HeartState.unavailable: unavailableSprite,
    };

    current = HeartState.available;
  }

  @override
  void update(double dt) {
    if (game.player.health < heartNumber) {
      current = HeartState.unavailable;
    } else {
      current = HeartState.available;
    }
    super.update(dt);
  }
}
