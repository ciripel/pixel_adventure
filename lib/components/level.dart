import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';

enum LevelName {
  level_01,
  level_02,
}

class Level extends World with HasGameRef {
  final LevelName levelName;
  final Player player;

  Level({this.levelName = LevelName.level_01, required this.player});
  late TiledComponent<FlameGame<World>> level;
  static const double tileSize = 16;
  static const double backgroundTileSize = tileSize * 4;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('${levelName.name}.tmx', Vector2.all(16));
    add(level);

    // _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer<TileLayer>('Background');

    final numTilesY = (game.size.y / backgroundTileSize).floor();
    final numTilesX = (game.size.x / backgroundTileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue<String>('BackgroundColor');

      for (var y = 0; y < game.size.y / numTilesY; y++) {
        for (var x = 0; x < numTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(x * backgroundTileSize, y * backgroundTileSize - backgroundTileSize),
          );

          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Saw':
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: spawnPoint.properties.getValue<bool>('isVertical') ?? false,
              offNeg: spawnPoint.properties.getValue<double>('offNeg') ?? 0,
              offPos: spawnPoint.properties.getValue<double>('offPos') ?? 0,
              speedMultiplier: spawnPoint.properties.getValue<double>('speedMultiplier') ?? 1,
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;

          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );

            player.collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            player.collisionBlocks.add(block);
            add(block);
        }
      }
    }
  }
}
