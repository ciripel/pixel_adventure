import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';

enum LevelName {
  level_01(60000),
  level_02(60000),
  level_03(300000);

  final int maxPointsCoefficient;
  const LevelName([this.maxPointsCoefficient = 0]);
}

class Level extends World with HasGameReference {
  final LevelName levelName;
  final Player player;

  Level({this.levelName = LevelName.level_01, required this.player});
  late TiledComponent<FlameGame<World>> currentLevel;
  static const double tileSize = 16;

  List<Fruit> fruits = [];
  bool checkpointActive = false;
  bool started = false;
  bool complete = false;
  Stopwatch stopwatch = Stopwatch();
  Vector2 startPosition = Vector2.zero();
  Vector2 endPosition = Vector2.zero();

  void init() {
    checkpointActive = false;
    started = false;
    complete = false;
  }

  @override
  FutureOr<void> onLoad() async {
    currentLevel = await TiledComponent.load('${levelName.name}.tmx', Vector2.all(16));
    add(currentLevel);

    // _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = currentLevel.tileMap.getLayer<TileLayer>('Background');
    if (backgroundLayer == null) return;

    final backgroundColor = backgroundLayer.properties.getValue<String>('BackgroundColor');
    final backgroundTile = BackgroundTile(color: backgroundColor ?? 'Gray', position: Vector2(0, 0));
    add(backgroundTile);
  }

  void _spawningObjects() {
    final spawnPointsLayer = currentLevel.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'StartPosition':
            startPosition = Vector2(spawnPoint.x, spawnPoint.y);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: FruitType.fromFilename(spawnPoint.name),
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            fruits.add(fruit);
            add(fruit);
            break;
          case 'Saw':
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: spawnPoint.properties.getValue<bool>('isVertical') ?? Saw().isVertical,
              offNeg: spawnPoint.properties.getValue<double>('offNeg') ?? Saw().offNeg,
              offPos: spawnPoint.properties.getValue<double>('offPos') ?? Saw().offPos,
              speedMultiplier: spawnPoint.properties.getValue<double>('speedMultiplier') ?? Saw().speedMultiplier,
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
          case 'Chicken':
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue<double>('offNeg') ?? Chicken().offNeg,
              offPos: spawnPoint.properties.getValue<double>('offPos') ?? Chicken().offPos,
            );
            add(chicken);
            break;
          case 'EndPosition':
            endPosition = Vector2(spawnPoint.x, spawnPoint.y);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = currentLevel.tileMap.getLayer<ObjectGroup>('Collisions');

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
