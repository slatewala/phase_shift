import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/obstacle.dart';
import '../game/phase_game.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import 'phase_painter.dart';
import 'start_screen.dart';

/// Full-screen game widget.  Owns the ticker loop and responds to taps.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final PhaseGame _game = PhaseGame();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  // Phase-shift crossfade animation (0 → 1 over 200 ms).
  double _phaseT = 1.0;
  Lane _prevSolidLane = Lane.light;
  static const double _phaseDuration = 0.20; // 200 ms
  double _phaseElapsed = 0.0;

  // Monotonic clock for visual effects (divider pulse, etc.).
  double _clock = 0.0;

  @override
  void initState() {
    super.initState();

    _game.onStageUp = _onStageUp;
    _game.onLevelUp = _onLevelUp;
    _game.onCollision = _onCollision;

    _ticker = createTicker(_onTick);
    _startGame();
  }

  void _startGame() {
    _lastTick = Duration.zero;
    _clock = 0;
    _phaseT = 1.0;
    _phaseElapsed = 0;
    _prevSolidLane = Lane.light;
    _game.start();
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final double dt =
        _lastTick == Duration.zero ? 0 : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.5) return; // skip enormous jumps

    _clock += dt;

    // Advance crossfade.
    if (_phaseT < 1.0) {
      _phaseElapsed += dt;
      _phaseT = (_phaseElapsed / _phaseDuration).clamp(0.0, 1.0);
    }

    // Feed screen size into game model.
    final Size sz = MediaQuery.of(context).size;
    _game.screenWidth = sz.width;
    _game.screenHeight = sz.height;

    _game.update(dt);

    if (_game.gameOver) {
      _ticker.stop();
      _lastTick = Duration.zero;
      ScoreService.instance.submit(_game.stage);
    }

    setState(() {}); // repaint
  }

  // ---- sound callbacks ----------------------------------------------------

  void _onStageUp() => SoundService.instance.play('tick');
  void _onLevelUp() => SoundService.instance.play('levelup');

  void _onCollision() {
    SoundService.instance.play('fail');
    Future.delayed(const Duration(milliseconds: 400), () {
      SoundService.instance.play('gameover');
    });
  }

  // ---- tap handler --------------------------------------------------------

  void _onTap() {
    if (_game.gameOver) return;
    _prevSolidLane = _game.solidLane;
    _game.toggleLane();
    // Reset crossfade when lane actually changed.
    if (_game.solidLane != _prevSolidLane) {
      _phaseT = 0.0;
      _phaseElapsed = 0.0;
      SoundService.instance.play('tap');
    }
  }

  // ---- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _onTap(),
      child: Stack(
        children: [
          // The game canvas.
          CustomPaint(
            painter: PhasePainter(
              game: _game,
              phaseT: _phaseT,
              tick: _clock,
            ),
            size: Size.infinite,
          ),

          // HUD — stage counter (top-centre).
          if (_game.running)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'STAGE ${_game.stage}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

          // Game-over overlay.
          if (_game.gameOver)
            _buildGameOver(context),
        ],
      ),
    );
  }

  Widget _buildGameOver(BuildContext context) {
    final bool isNewBest = _game.stage >= ScoreService.instance.highScore &&
        ScoreService.instance.highScore > 0;
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Stage ${_game.stage}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Best: ${ScoreService.instance.highScore}',
              style: TextStyle(
                color: isNewBest ? Colors.amberAccent : Colors.white70,
                fontSize: 18,
              ),
            ),
            if (isNewBest) ...[
              const SizedBox(height: 4),
              const Text(
                'NEW BEST!',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const StartScreen()),
                );
              },
              child: const Text(
                'MAIN MENU',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _game.dispose();
    super.dispose();
  }
}
