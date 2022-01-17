import 'package:flutter/material.dart';

class Ball {
  double aX; //加速度
  double aY; //加速度Y
  double vX; //速度X
  double vY; //速度Y
  double x; //点位X
  double y; //点位Y
  Color color; //颜色
  double r; //小球半径
  double radians;

  /// 当前x与y的角度
  PaintingStyle style;

  Ball(
      {required this.x,
      required this.y,
      this.color = Colors.white,
      required this.r,
      this.aX = 0,
      this.aY = 0,
      this.vX = 0,
      this.vY = 0,
      this.style = PaintingStyle.stroke,
      required this.radians});
}
