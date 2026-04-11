import 'package:audioplayers/audioplayers.dart';

/// Crash-safe sound service.
///
/// Some Android devices crash with PlayerMode.lowLatency due to
/// MediaPlayer.getPlaybackParams IllegalStateException. This service
/// uses mediaPlayer mode (safe) and catches all errors.
class SoundService {
  static final SoundService _singleton = SoundService._internal();
  static SoundService get instance => _singleton;
  factory SoundService() => _singleton;
  SoundService._internal();

  final Map<String, AudioPlayer> _players = {};
  bool _enabled = true;

  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;

  Future<void> init() async {}

  Future<void> play(String name) async {
    if (!_enabled) return;
    try {
      // Use a fresh player each time to avoid state issues on Android
      final existing = _players[name];
      if (existing != null) {
        try { await existing.stop(); } catch (_) {}
        try { await existing.dispose(); } catch (_) {}
      }

      final p = AudioPlayer();
      _players[name] = p;
      // Use default mediaPlayer mode — lowLatency crashes on some devices
      await p.setVolume(1.0);
      await p.setReleaseMode(ReleaseMode.stop);
      await p.play(AssetSource('sounds/$name.wav'));
    } catch (_) {
      // Never crash the game for sound failures
    }
  }

  // Convenience methods
  Future<void> playTap() => play('tap');
  Future<void> playSuccess() => play('success');
  Future<void> playFail() => play('fail');
  Future<void> playCorrect() => play('correct');
  Future<void> playWrong() => play('wrong');
  Future<void> playTick() => play('tick');
  Future<void> playWarning() => play('warning');
  Future<void> playGameOver() => play('gameover');
  Future<void> playLevelUp() => play('levelup');
  Future<void> playPour() => play('pour');
  Future<void> playSplash() => play('splash');
  Future<void> playEvolve() => play('evolve');
  Future<void> playSurvive() => play('survive');
  Future<void> playExtinct() => play('extinct');

  bool get muted => !_enabled;
  void toggleMute() { _enabled = !_enabled; }

  Future<void> dispose() async {
    for (final p in _players.values) {
      try { await p.stop(); } catch (_) {}
      try { await p.dispose(); } catch (_) {}
    }
    _players.clear();
  }
}
