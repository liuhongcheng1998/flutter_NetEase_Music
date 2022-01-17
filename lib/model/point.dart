class Point {
  late double x;
  late double y;
  late double angle;
  Point({required this.x, required this.y, required this.angle});

  Point.formMap(map) {
    Point(x: map['x'], y: map['y'], angle: map['angle']);
  }
}
