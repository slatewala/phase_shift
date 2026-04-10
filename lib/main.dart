import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/score_service.dart';
import 'services/sound_service.dart';
import 'ui/start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide system UI for full-screen feel.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialise services.
  await Future.wait([
    SoundService.instance.init(),
    ScoreService.instance.load(),
  ]);

  runApp(const PhaseShiftApp());
}

class PhaseShiftApp extends StatelessWidget {
  const PhaseShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phase Shift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      ),
      home: const StartScreen(),
    );
  }
}
