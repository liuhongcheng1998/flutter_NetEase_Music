import 'ball.dart';

class RotateCircle {
  double r;
  double x;
  double y;
  double opacity;
  Ball ball;
  RotateCircle({
    required this.r,
    this.x = 0,
    this.y = 0,
    required this.ball,
    this.opacity = 1,
  });
}
