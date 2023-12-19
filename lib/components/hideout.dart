import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum HideoutType {
  brick();

  final String filename;
  // ignore: unused_element
  const HideoutType([this.filename = 'Brick']);

  static HideoutType fromFilename(String filename) {
    switch (filename) {
      case 'Brick':
        return HideoutType.brick;
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
