import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class LeftButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  LeftButton({super.priority = 10, super.anchor = Anchor.bottomLeft});

  static const double margin = 32;
  static const double buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/Left_button.png'));
    position = Vector2(margin, 240 - margin);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.horizontalMovement = -1;

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.horizontalMovement = 0;
    super.onTapUp(event);
  }
}
