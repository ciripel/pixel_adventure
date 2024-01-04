import 'package:flame/components.dart';
import 'package:pixel_adventure/components/HUD/health.dart';
import 'package:pixel_adventure/components/HUD/settings_button.dart';
import 'package:pixel_adventure/constants/constants.dart';
import 'package:pixel_adventure/helpers/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Hud extends PositionComponent with HasGameReference<PixelAdventure> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 10,
  });

  late TextComponent _scoreTextComponent;
  late TextComponent _timerTextComponent;

  @override
  Future<void> onLoad() async {
    _printLives();
    _printTimer();
    _printSettingsBtn();
    await _printScore();
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.player.totalScore}';
    _timerTextComponent.text = format(game.level.stopwatch.elapsed);
  }

  void _printLives() {
    for (var i = 1; i <= game.player.health; i++) {
      final positionX = 10 * i;
      add(
        Health(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), 10),
          size: Vector2.all(20),
        ),
      );
    }
  }

  Future<void> _printScore() async {
    _scoreTextComponent = TextComponent(
      text: '${game.player.totalScore}',
      textRenderer: TextPaint(style: Constants.hudTextStyle),
      anchor: Anchor.centerRight,
      position: Vector2(game.size.x - 70, 20),
    );
    add(_scoreTextComponent);

    final fruitSprite = await game.loadSprite('Items/Fruits/Melon.png', srcSize: Vector2.all(32));
    add(
      SpriteComponent(
        priority: priority,
        sprite: fruitSprite,
        position: Vector2(game.size.x - 55, 20),
        size: Vector2.all(32),
        anchor: Anchor.center,
      ),
    );
  }

  void _printTimer() {
    _timerTextComponent = TextComponent(
      text: format(game.level.stopwatch.elapsed),
      textRenderer: TextPaint(style: Constants.hudTextStyle),
      anchor: Anchor.center,
      position: Vector2(game.size.x / 2, 20),
    );
    add(_timerTextComponent);
  }

  void _printSettingsBtn() async {
    final settingsBtn = SettingsButton();
    add(settingsBtn);
  }
}
