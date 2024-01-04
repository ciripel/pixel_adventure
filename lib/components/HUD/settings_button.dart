import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class SettingsButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  SettingsButton({super.priority = 10, super.anchor = Anchor.topRight});

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('Menu/Buttons/Settings.png'), srcSize: Vector2.all(32));
    position = Vector2(game.size.x - 5, 5);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.overlays.add('OptionsMenu');
    super.onTapDown(event);
  }
}
