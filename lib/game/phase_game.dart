import 'dart:math';

import 'package:flutter/foundation.dart';

import 'obstacle.dart';

/// Core game model.  Owns obstacles, the active (solid) lane, score,
/// collision detection and difficulty curve.
class PhaseGame extends ChangeNotifier {
  PhaseGame();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------
  static const double _baseSpeed = 300.0; // px/s at stage 1
  static const double _speedPerStage = 10.0;
  static const double _maxSpeed = 800.0;
  static const double _stageDuration = 5.0; // seconds per stage
  static const double _playerYFraction = 0.75; // 75% down screen
  static const double _playerRadius = 18.0;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  final List<Obstacle> obstacles = [];
  final Random _rng = Random();

  Lane _solidLane = Lane.light;
  Lane get solidLane => _solidLane;

  bool _running = false;
  bool get running => _running;

  bool _gameOver = false;
  bool get gameOver => _gameOver;

  int _stage = 1;
  int get stage => _stage;

  double _stageTimer = 0.0; // seconds within current stage
  double _spawnTimer = 0.0; // seconds since last spawn

  /// Callbacks the UI hooks into for sound cues.
  VoidCallback? onStageUp;
  VoidCallback? onLevelUp; // every 10 stages
  VoidCallback? onCollision;

  // Cached screen metrics – set once per frame by the game screen.
  double screenWidth = 0;
  double screenHeight = 0;

  // ---------------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------------
  double get speed =>
      (_baseSpeed + (_stage - 1) * _speedPerStage).clamp(0, _maxSpeed);

  double get spawnInterval {
    // Start at 0.9 s, decrease to 0.3 s.
    return (0.9 - (_stage - 1) * 0.03).clamp(0.3, 0.9);
  }

  double get playerY => screenHeight * _playerYFraction;

  double get laneWidth => screenWidth / 2;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void start() {
    obstacles.clear();
    _solidLane = Lane.light;
    _stage = 1;
    _stageTimer = 0;
    _spawnTimer = 0;
    _gameOver = false;
    _running = true;
    notifyListeners();
  }

  void toggleLane() {
    if (!_running || _gameOver) return;
    _solidLane = _solidLane == Lane.light ? Lane.dark : Lane.light;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Per-frame update
  // ---------------------------------------------------------------------------
  void update(double dt) {
    if (!_running || _gameOver) return;

    // --- stage timer ---
    _stageTimer += dt;
    if (_stageTimer >= _stageDuration) {
      _stageTimer -= _stageDuration;
      _stage++;
      onStageUp?.call();
      if (_stage % 10 == 0) {
        onLevelUp?.call();
      }
    }

    // --- move obstacles ---
    final double dist = speed * dt;
    for (final obs in obstacles) {
      obs.y += dist;
    }

    // --- remove off-screen ---
    obstacles.removeWhere((o) => o.y > screenHeight + 100);

    // --- spawn ---
    _spawnTimer += dt;
    if (_spawnTimer >= spawnInterval) {
      _spawnTimer -= spawnInterval;
      _spawnObstacles();
    }

    // --- collision ---
    if (_checkCollision()) {
      _gameOver = true;
      _running = false;
      onCollision?.call();
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _spawnObstacles() {
    final double w = 0.4 + _rng.nextDouble() * 0.4; // 0.4 – 0.8
    final double h = 30.0 + _rng.nextDouble() * 50.0; // 30 – 80

    if (_stage >= 16 && _rng.nextDouble() < 0.5) {
      // Both-lane spawn — player must time the shift between gaps.
      final double w2 = 0.4 + _rng.nextDouble() * 0.4;
      final double h2 = 30.0 + _rng.nextDouble() * 50.0;
      obstacles.add(Obstacle(lane: Lane.light, y: -h, width: w, height: h));
      obstacles.add(Obstacle(lane: Lane.dark, y: -h2, width: w2, height: h2));
    } else {
      final Lane lane = _rng.nextBool() ? Lane.light : Lane.dark;
      obstacles.add(Obstacle(lane: lane, y: -h, width: w, height: h));
    }
  }

  bool _checkCollision() {
    final double pY = playerY;
    for (final obs in obstacles) {
      if (obs.lane != _solidLane) continue;

      // Horizontal: obstacle is centred in its lane.
      // We only need vertical overlap with the player circle.
      final double obsTop = obs.y;
      final double obsBottom = obs.y + obs.height;
      final double pTop = pY - _playerRadius;
      final double pBottom = pY + _playerRadius;

      if (obsBottom > pTop && obsTop < pBottom) {
        // Horizontal check: obstacle rect vs player circle centre-x
        final double laneCentreX =
            obs.lane == Lane.light ? laneWidth / 2 : laneWidth + laneWidth / 2;
        final double obsW = obs.width * laneWidth;
        final double obsLeft = laneCentreX - obsW / 2;
        final double obsRight = laneCentreX + obsW / 2;

        // Player centre x = lane centre
        final double px = _solidLane == Lane.light
            ? laneWidth / 2
            : laneWidth + laneWidth / 2;

        if (px + _playerRadius > obsLeft && px - _playerRadius < obsRight) {
          return true;
        }
      }
    }
    return false;
  }
}
