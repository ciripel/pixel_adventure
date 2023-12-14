import 'package:flutter/material.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class LevelComplete extends StatelessWidget {
  // Reference to parent game.
  final PixelAdventure game;

  const LevelComplete({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 0.6);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 0.9);

    final fruitsPoints = game.level.fruitsPoints;
    final enemiesPoints = game.level.enemiesPoints;
    final healthCoefficient = ((game.player.health / 3) * 100).floor();
    final completeTimePoints = game.level.completeTimePoints;
    final totalPoints = game.level.totalPoints;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 400,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Level Complete',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Fruits collected: $fruitsPoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Enemies killed: $enemiesPoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Health coefficient: $healthCoefficient%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Level complete time points: $completeTimePoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Total points: $totalPoints',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('LevelComplete');
                    game.player.previousScore = game.player.totalScore;
                    loadNextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 30.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loadNextLevel() {
    if (game.level.levelName.index < LevelName.values.length - 1) {
      return game.initializeGame(levelName: LevelName.values[game.level.levelName.index + 1]);
    }
    game.overlays.add('GameOver');
  }
}
