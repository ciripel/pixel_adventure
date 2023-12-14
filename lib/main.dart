import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pixel_adventure/overlays/game_over.dart';
import 'package:pixel_adventure/overlays/level_complete.dart';
import 'package:pixel_adventure/overlays/main_menu.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  final version = Pubspec.parse(await rootBundle.loadString('pubspec.yaml')).version.toString();

  final game = PixelAdventure();
  runApp(
    GameWidget(
      game: kDebugMode ? PixelAdventure() : game,
      overlayBuilderMap: {
        'MainMenu': (_, PixelAdventure game) => MainMenu(game: game, version: version),
        'LevelComplete': (_, PixelAdventure game) => LevelComplete(game: game),
        'GameOver': (_, PixelAdventure game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
