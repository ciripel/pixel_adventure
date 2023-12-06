import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;

  BackgroundTile({
    this.color = 'Gray',
    super.position,
  });

  final double scrollSpeed = 0.4;

  @override
  FutureOr<void> onLoad() {
    priority = -10;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    final scrollHeight = (game.size.y / Level.backgroundTileSize).floor();
    if (position.y > scrollHeight * Level.backgroundTileSize) position.y = -Level.backgroundTileSize;
    super.update(dt);
  }
}
