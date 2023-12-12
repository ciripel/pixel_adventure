import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pixel_adventure/components/hud.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  final player = Player(character: Character.virtualGuy);
  late Level level;
  late JoystickComponent _joystick;
  late JumpButton _jumpButton;
  bool isMobile = false;
  bool playSoundEffects = true;
  double soundEffectsVolume = 1.0;
  bool playMusic = true;

  @override
  FutureOr<void> onLoad() async {
    debugPrint('Version: ${Pubspec.parse(await rootBundle.loadString('pubspec.yaml')).version}');
    await images.loadAllImages();

    isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android;

    if (isMobile) _addJoystick();
    _setCamera();

    _initializeGame(loadHud: true);

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
    _initializeGame();
  }

  void loadNextLevel() {
    if (level.levelName.index < LevelName.values.length - 1) {
      return _initializeGame(levelName: LevelName.values[level.levelName.index + 1]);
    }
    overlays.add('GameOver');
  }

  void _initializeGame({bool loadHud = false, LevelName levelName = LevelName.level_01}) {
    world = level = Level(player: player, levelName: levelName)..init();
    player.init();

    if (loadHud) camera.viewport.add(Hud());
  }
}
