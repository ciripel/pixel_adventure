import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/heart.dart';
import 'package:pixel_adventure/components/hideout.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/helpers/custom_shape.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum LevelName {
  level_01(
    maxPointsCoefficient: 60000,
    levelHeight: 368,
    background: CustomShape.rectangle(left: 0, top: 0, width: 640, height: 368),
    cameraBounds: CustomShape.rectangle(left: -1092, top: -512, width: 2824, height: 1397),
  ),
  level_02(
    maxPointsCoefficient: 60000,
    levelHeight: 368,
    background: CustomShape.rectangle(left: 0, top: 0, width: 640, height: 368),
    cameraBounds: CustomShape.rectangle(left: -1092, top: -512, width: 2824, height: 1397),
  ),
  level_03(
    maxPointsCoefficient: 300000,
    levelHeight: 368,
    background: CustomShape.rectangle(left: 0, top: 0, width: 640, height: 368),
    cameraBounds: CustomShape.rectangle(left: -1092, top: -512, width: 2824, height: 1397),
  ),
  level_04(
    maxPointsCoefficient: 600000,
    levelHeight: 464,
    background: CustomShape.rectangle(left: 16, top: 16, width: 3856, height: 432),
    cameraBounds: CustomShape.rectangle(left: -1082, top: -512, width: 6052, height: 1489),
  );

  final int maxPointsCoefficient;
  final int levelHeight;
  final CustomShape background;
  final CustomShape cameraBounds;
  const LevelName({
    required this.maxPointsCoefficient,
    required this.levelHeight,
    required this.background,
    required this.cameraBounds,
  });
}

class Level extends World with HasGameReference<PixelAdventure> {
  final LevelName levelName;
  final Player player;

  Level({this.levelName = LevelName.level_01, required this.player});
  late TiledComponent<FlameGame<World>> currentLevel;
  late Background background;

  List<Fruit> fruits = [];
  bool checkpointActive = false;
  bool started = false;
  bool complete = false;
  Stopwatch stopwatch = Stopwatch();
  Vector2 startPosition = Vector2.zero();
  Vector2 endPosition = Vector2.zero();

  int fruitsPoints = 0;
  int enemiesPoints = 0;
  int completeTimePoints = 0;
  int totalPoints = 0;

  void init() {
    checkpointActive = false;
    started = false;
    complete = false;
  }

  void resetScore() {
    fruitsPoints = 0;
    enemiesPoints = 0;
    completeTimePoints = 0;
    totalPoints = 0;
  }

  @override
  FutureOr<void> onLoad() async {
    currentLevel = await TiledComponent.load('${levelName.name}.tmx', Vector2.all(16));
    add(currentLevel);

    _addBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _addBackground() {
    background = Background(
      position: Vector2(levelName.background.left, levelName.background.top),
      size: Vector2(levelName.background.width, levelName.background.height),
    );
    add(background);
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
          case 'Heart':
            final heart = Heart(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(heart);
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
          case 'Hideout':
            final hideout = Hideout(
              type: HideoutType.fromFilename(collision.properties.getValue<String>('type') ?? Hideout().type.filename),
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            add(hideout);

            final isBlock = collision.properties.getValue<bool>('isBlock') ?? true;
            if (!isBlock) break;

            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            player.collisionBlocks.add(block);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            )..priority;
            player.collisionBlocks.add(block);
            add(block);
        }
      }
    }
  }
}
