import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pixel_adventure/components/hud.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/left_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/right_button.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  final player = Player(character: Character.virtualGuy);
  late Level level;
  late JoystickComponent _joystick;
  bool useJoystick = false;
  late LeftButton _leftButton;
  late RightButton _rightButton;
  late JumpButton _jumpButton;
  bool isMobile = false;
  bool playSoundEffects = true;
  double soundEffectsVolume = 1.0;
  bool playMusic = false;

  @override
  FutureOr<void> onLoad() async {
    debugPrint('Version: ${Pubspec.parse(await rootBundle.loadString('pubspec.yaml')).version}');
    await images.loadAllImages();
    isMobile = true;
    // isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android;

    if (isMobile) _addControls();
    _setCamera();

    initializeGame(loadHud: true);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isMobile && useJoystick) _updateJoystick();
    if (player.health <= 0) overlays.add('GameOver');
    super.update(dt);
  }

  void _addControls() async {
    _joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
      anchor: Anchor.bottomLeft,
      position: Vector2(JumpButton.margin, 240 - JumpButton.margin),
    );
    _leftButton = LeftButton();
    _rightButton = RightButton();
    _jumpButton = JumpButton();

    if (useJoystick) addAll([_joystick, _jumpButton]);

    if (!useJoystick) addAll([_leftButton, _rightButton, _jumpButton]);
  }

  void _setCamera() {
    camera = CameraComponent.withFixedResolution(
      width: 500,
      height: 240,
      hudComponents: isMobile
          ? useJoystick
              ? [_joystick, _jumpButton]
              : [_leftButton, _rightButton, _jumpButton]
          : [],
    );

    camera.follow(player);
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
    player.health = 3;
    initializeGame();
  }

  void initializeGame({bool loadHud = false, LevelName levelName = LevelName.level_01}) {
    world = level = Level(player: player, levelName: levelName)
      ..init()
      ..resetScore();
    player.init();

    if (loadHud) camera.viewport.add(Hud());
  }
}
