import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum HideoutType {
  brick('Brick (48x48)'),
  grassLeftSide('Grass Left Side (48x96)');

  final String filename;

  const HideoutType(this.filename);

  static HideoutType fromFilename(String filename) {
    switch (filename) {
      case 'Brick':
        return HideoutType.brick;
      case 'Grass Left Side':
        return HideoutType.grassLeftSide;
      default:
        return HideoutType.brick;
    }
  }
}

class Hideout extends SpriteComponent with HasGameReference<PixelAdventure> {
  final HideoutType type;
  Hideout({
    super.position,
    super.size,
    super.priority = 9,
    super.anchor = Anchor.topLeft,
    this.type = HideoutType.brick,
  });

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('Terrain/${type.filename}.png');
    return super.onLoad();
  }
}
