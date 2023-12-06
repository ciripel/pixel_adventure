import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum HeartState {
  available,
  unavailable,
}

class HeartHealthComponent extends SpriteGroupComponent<HeartState> with HasGameRef<PixelAdventure> {
  final int heartNumber;

  HeartHealthComponent({
    required this.heartNumber,
    required super.position,
    required super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final availableSprite = await game.loadSprite(
      'HUD/Heart.png',
      srcSize: Vector2.all(16),
    );

    final unavailableSprite = await game.loadSprite(
      'HUD/Heart_empty.png',
      srcSize: Vector2.all(16),
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
