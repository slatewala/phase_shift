import 'package:shared_preferences/shared_preferences.dart';

/// Persists the highest stage reached.
class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  static const String _key = 'phase_shift_high_score';

  int _highScore = 0;
  int get highScore => _highScore;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_key) ?? 0;
  }

  Future<void> submit(int stage) async {
    if (stage <= _highScore) return;
    _highScore = stage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _highScore);
  }
}
