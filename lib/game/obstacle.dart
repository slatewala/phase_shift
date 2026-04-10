/// Which lane the obstacle belongs to.
enum Lane { light, dark }

/// A single obstacle that scrolls down one lane.
class Obstacle {
  Obstacle({
    required this.lane,
    required this.y,
    required this.width,
    required this.height,
  });

  final Lane lane;

  /// Current vertical position (top edge). Increases as obstacle moves down.
  double y;

  /// Width as a fraction of the lane width (0.4 – 0.8).
  final double width;

  /// Absolute height in logical pixels (30 – 80).
  final double height;
}
