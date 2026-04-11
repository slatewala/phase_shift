import 'package:audioplayers/audioplayers.dart';

/// Crash-proof sound service.
///
/// Each play() creates an independent AudioPlayer that self-disposes
/// after playback. No shared state, no stop/dispose race conditions.
/// Cannot crash regardless of Android MediaPlayer state.
class SoundService {
  static final SoundService _singleton = SoundService._internal();
  static SoundService get instance => _singleton;
  factory SoundService() => _singleton;
  SoundService._internal();

  bool _enabled = true;
  bool get enabled => _enabled;
  set enabled(bool v) => _enabled = v;
  bool get muted => !_enabled;
  void toggleMute() { _enabled = !_enabled; }

  Future<void> init() async {}

  /// Fire-and-forget: spawns a new player, plays the sound, auto-disposes.
  /// No shared state means no race conditions or IllegalStateException.
  Future<void> play(String name) async {
    if (!_enabled) return;
    try {
      final p = AudioPlayer();
      // Auto-dispose when done playing
      p.onPlayerComplete.listen((_) {
        try { p.dispose(); } catch (_) {}
      });
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(1.0);
      await p.play(AssetSource('sounds/$name.wav'));
    } catch (_) {
      // Absolutely never crash for sound
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

  Future<void> dispose() async {}
}
