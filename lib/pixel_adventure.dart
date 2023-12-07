import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pixel_adventure/components/hud.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  final player = Player();
  late Level level;
  late JoystickComponent _joystick;
  late JumpButton _jumpButton;
  bool isMobile = false;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android;

    if (isMobile) _addJoystick();
    _setCamera();

    _initializeGame(true);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isMobile) _updateJoystick();
    if (player.health <= 0) overlays.add('GameOver');
    super.update(dt);
  }

  void _setCamera() {
    camera = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      hudComponents: isMobile ? [_joystick, _jumpButton] : [],
    );

    camera.viewfinder.anchor = Anchor.topLeft;
  }

  void _addJoystick() async {
    _joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
      margin: const EdgeInsets.only(left: 32, bottom: JumpButton.margin + JumpButton.buttonSize),
    );
    add(_joystick);
    _jumpButton = JumpButton();
    add(_jumpButton);
  }

  void _updateJoystick() {
    switch (_joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void reset() {
    player
      ..fruitsCollected = 0
      ..health = 3;
    _initializeGame(false);
  }

  void _initializeGame(bool loadHud) {
    level = Level(player: player);
    world = level;
    player
      ..gotHit = false
      ..velocity = Vector2.zero()
      ..horizontalMovement = 0
      ..scale.x = 1;

    if (loadHud) camera.viewport.add(Hud());
  }
}
