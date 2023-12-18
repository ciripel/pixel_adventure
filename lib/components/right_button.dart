import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/constants/constants.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class RightButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  RightButton({
    super.priority = 10,
    super.anchor = Anchor.bottomLeft,
  });

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/Right_button.png'));
    position = Vector2(
      Constants.controlsMargin + Constants.spaceBetweenButtons + Constants.controlsSize,
      Constants.verticalResolution - Constants.controlsMargin,
    );

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.horizontalMovement = 1;

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.horizontalMovement = 0;
    super.onTapUp(event);
  }
}
