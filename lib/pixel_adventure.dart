import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pixel_adventure/components/HUD/hud.dart';
import 'package:pixel_adventure/components/HUD/jump_button.dart';
import 'package:pixel_adventure/components/HUD/left_button.dart';
import 'package:pixel_adventure/components/HUD/right_button.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/constants/constants.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  final player = Player();
  late Level level;
  late JoystickComponent joystick;
  bool useJoystick = false;
  late LeftButton leftButton;
  late RightButton rightButton;
  late JumpButton _jumpButton;
  bool isMobile = false;

  bool playSoundEffects = true;
  double soundEffectsVolume = 1.0;

  bool playMusic = true;
  double musicVolume = 0.2;

  late AudioPlayer musicPlayer;

  late Uri? wcUri;
  late SessionData wcSession;

  @override
  FutureOr<void> onLoad() async {
    debugPrint('Version: ${Pubspec.parse(await rootBundle.loadString('pubspec.yaml')).version}');
    await images.loadAllImages();
    isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android;

    if (isMobile) addControls();
    setCamera();

    initializeGame(loadHud: true);

    await _initializeWc();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isMobile && useJoystick) _updateJoystick();
    if (player.health <= 0) overlays.add('GameOver');
    super.update(dt);
  }

  void addControls() async {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
      anchor: Anchor.bottomLeft,
      position: Vector2(
        Constants.controlsMargin,
        Constants.verticalResolution - Constants.controlsMargin,
      ),
    );

    leftButton = LeftButton();
    rightButton = RightButton();
    _jumpButton = JumpButton();
  }

  void setCamera() {
    camera = CameraComponent.withFixedResolution(
      width: Constants.horizontalResolution,
      height: Constants.verticalResolution,
    );

    camera.follow(player);
  }

  void _updateJoystick() {
    switch (joystick.direction) {
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
    camera.setBounds(
      Rectangle.fromLTWH(
        level.levelName.cameraBounds.left,
        level.levelName.cameraBounds.top,
        level.levelName.cameraBounds.width,
        level.levelName.cameraBounds.height,
      ),
      considerViewport: true,
    );

    if (loadHud) {
      camera.viewport.add(Hud());
      if (!isMobile) return;
      if (useJoystick) camera.viewport.addAll([joystick, _jumpButton]);
      if (!useJoystick) camera.viewport.addAll([leftButton, rightButton, _jumpButton]);
    }
  }

  Future<void> _initializeWc() async {
    final wcClient = await Web3App.createInstance(
      projectId: '0c88d9db42474f9a99586ece621824be',
      logLevel: LogLevel.info,
      metadata: const PairingMetadata(
        name: 'Pixel Adventure',
        description: 'Pixel Adventure',
        url: 'https://vps1.amitabha.xyz/',
        icons: ['https://avatars.githubusercontent.com/u/37701673?s=96&v=4'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://vps1.amitabha.xyz/',
        ),
      ),
    );

    // For a dApp, you would connect with specific parameters, then display
    // the returned URI.
    final resp = await wcClient.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:56'], // Binance Smart Chain  chain
          methods: ['personal_sign', 'eth_signTransaction'], // Requestable Methods, see MethodsConstants for reference
          events: ['chainChanged'], // Requestable Events, see EventsConstants for reference
        ),
      },
    );

    wcUri = resp.uri;
    debugPrint('$wcUri');

    // When completed hide the QR_Modal and show Main Menu
    resp.session.future.then((session) {
      overlays
        ..remove('WcQrModal')
        ..add('MainMenu');
      wcSession = session;
    });
  }
}
