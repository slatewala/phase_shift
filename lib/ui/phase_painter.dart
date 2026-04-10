import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/obstacle.dart';
import '../game/phase_game.dart';

/// Renders both lanes, obstacles, player characters, and visual effects.
class PhasePainter extends CustomPainter {
  PhasePainter({
    required this.game,
    required this.phaseT, // 0 → 1 crossfade progress
    required this.tick, // monotonic counter for divider pulse
  });

  final PhaseGame game;
  final double phaseT;
  final double tick;

  // Neon palette for the dark lane obstacles.
  static const List<Color> _neonColors = [
    Color(0xFF00FFFF),
    Color(0xFFFF00FF),
    Color(0xFF39FF14),
    Color(0xFFFF3131),
    Color(0xFFFFFF00),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double laneW = size.width / 2;

    _drawBackgrounds(canvas, size, laneW);
    _drawDivider(canvas, size, laneW);
    _drawObstacles(canvas, size, laneW);
    _drawPlayers(canvas, size, laneW);
  }

  // ---- backgrounds --------------------------------------------------------

  void _drawBackgrounds(Canvas canvas, Size size, double laneW) {
    // Light lane
    canvas.drawRect(
      Rect.fromLTWH(0, 0, laneW, size.height),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    // Dark lane
    canvas.drawRect(
      Rect.fromLTWH(laneW, 0, laneW, size.height),
      Paint()..color = const Color(0xFF1A1A2E),
    );
  }

  // ---- divider ------------------------------------------------------------

  void _drawDivider(Canvas canvas, Size size, double laneW) {
    final double pulse = 0.5 + 0.5 * math.sin(tick * 3.0);
    final Paint divPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF888888),
        const Color(0xFF00FFFF),
        pulse,
      )!
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(laneW, 0), Offset(laneW, size.height), divPaint);
  }

  // ---- obstacles ----------------------------------------------------------

  void _drawObstacles(Canvas canvas, Size size, double laneW) {
    for (final obs in game.obstacles) {
      final bool inLight = obs.lane == Lane.light;
      final double laneCX = inLight ? laneW / 2 : laneW + laneW / 2;
      final double w = obs.width * laneW;
      final Rect rect = Rect.fromCenter(
        center: Offset(laneCX, obs.y + obs.height / 2),
        width: w,
        height: obs.height,
      );

      if (inLight) {
        // Dark-coloured rectangle on the light lane.
        final Paint p = Paint()..color = const Color(0xFF333333);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          p,
        );
      } else {
        // Neon rectangle on the dark lane.
        final Color neon =
            _neonColors[obs.hashCode % _neonColors.length];
        final Paint p = Paint()..color = neon;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          p,
        );
        // Glow
        final Paint glow = Paint()
          ..color = neon.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(6)),
          glow,
        );
      }
    }
  }

  // ---- players ------------------------------------------------------------

  void _drawPlayers(Canvas canvas, Size size, double laneW) {
    final double pY = game.playerY;
    final double lightX = laneW / 2;
    final double darkX = laneW + laneW / 2;
    const double r = 18;

    final bool solidIsLight = game.solidLane == Lane.light;

    // The crossfade value (phaseT) animates 0→1 on each toggle.
    // When solidIsLight: light alpha goes from ghosty→solid as phaseT rises.
    // The *previous* solid lane fades out symmetrically.

    final double solidAlpha = ui.lerpDouble(0.3, 1.0, phaseT)!;
    final double ghostAlpha = ui.lerpDouble(1.0, 0.3, phaseT)!;

    _drawPlayerCircle(
      canvas,
      Offset(lightX, pY),
      r,
      solidIsLight ? solidAlpha : ghostAlpha,
      solidIsLight,
      isLightLane: true,
    );
    _drawPlayerCircle(
      canvas,
      Offset(darkX, pY),
      r,
      solidIsLight ? ghostAlpha : solidAlpha,
      !solidIsLight,
      isLightLane: false,
    );
  }

  void _drawPlayerCircle(
    Canvas canvas,
    Offset centre,
    double r,
    double alpha,
    bool solid, {
    required bool isLightLane,
  }) {
    final Color base = isLightLane
        ? const Color(0xFF2979FF)
        : const Color(0xFF00FFFF);

    if (solid) {
      // Glow
      final Paint glow = Paint()
        ..color = base.withValues(alpha: 0.4 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(centre, r + 6, glow);

      // Filled
      final Paint fill = Paint()..color = base.withValues(alpha: alpha);
      canvas.drawCircle(centre, r, fill);
    } else {
      // Ghost outline
      final Paint outline = Paint()
        ..color = base.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(centre, r, outline);
    }
  }

  @override
  bool shouldRepaint(covariant PhasePainter oldDelegate) => true;
}
