import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/overlays/game_over.dart';
import 'package:pixel_adventure/overlays/main_menu.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final game = PixelAdventure();
  runApp(
    GameWidget(
      game: kDebugMode ? PixelAdventure() : game,
      overlayBuilderMap: {
        'MainMenu': (_, PixelAdventure game) => MainMenu(game: game),
        'GameOver': (_, PixelAdventure game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
