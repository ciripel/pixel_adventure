import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/constants/constants.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameReference<PixelAdventure>, TapCallbacks {
  JumpButton({
    super.priority = 10,
    super.anchor = Anchor.bottomRight,
  });

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/Jump_button.png'));
    position = Vector2(
      Constants.horizontalResolution - Constants.controlsMargin,
      Constants.verticalResolution - Constants.controlsMargin,
    );

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
