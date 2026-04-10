import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';

/// Title / start screen.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _play() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _toggleSound() {
    setState(() {
      SoundService.instance.enabled = !SoundService.instance.enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int best = ScoreService.instance.highScore;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final double t = _pulse.value;
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Color.lerp(
                            const Color(0xFF00FFFF),
                            const Color(0xFFFF00FF),
                            t,
                          )!,
                          Color.lerp(
                            const Color(0xFFFF00FF),
                            const Color(0xFF00FFFF),
                            t,
                          )!,
                        ],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'PHASE\nSHIFT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
              const Text(
                'Infinite Survival',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 48),

              // Play button
              ElevatedButton(
                onPressed: _play,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (best > 0)
                Text(
                  'BEST: STAGE $best',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),

              const SizedBox(height: 32),

              // Sound toggle
              IconButton(
                onPressed: _toggleSound,
                icon: Icon(
                  SoundService.instance.enabled
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: Colors.white38,
                  size: 28,
                ),
              ),

              const SizedBox(height: 24),

              // How to play
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Tap to shift between light and dark lanes.\n'
                  'Avoid obstacles in your solid lane.\n'
                  'Survive as long as you can!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
