import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Lightweight fire-and-forget sound effects.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final Map<String, AudioPlayer> _players = {};
  bool _enabled = true;
  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      for (final p in _players.values) {
        p.stop();
      }
    }
  }

  /// Pre-create players for the sounds we use.
  Future<void> init() async {
    for (final name in ['tap', 'tick', 'fail', 'gameover', 'levelup']) {
      _players[name] = AudioPlayer();
    }
  }

  Future<void> play(String name) async {
    if (!_enabled) return;
    try {
      final player = _players[name];
      if (player == null) return;
      await player.stop();
      await player.play(AssetSource('sounds/$name.wav'));
    } catch (e) {
      debugPrint('SoundService: could not play $name — $e');
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}
