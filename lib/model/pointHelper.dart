import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:netease_app/model/point.dart';

class PointHelper {
  /// r为圆的半径， r1为正方形长度一半
  /// 根据圆的公式计算圆上任意一点
  static Point getPoint({required double r, required double r1, angle}) {
    double y;
    double x;
    angle ??= math.Random().nextDouble() * math.pi * 2;
    y = r1 + r * math.sin(angle);
    x = r1 + r * math.cos(angle);
    return Point(x: x, y: y, angle: angle);
  }

  /// https://blog.csdn.net/jiexiaopei_2004/article/details/48496475
  /// 控制点的计算, 可以以此画圆 θ 为圆N等分的角度， 不要大于90度
  /// (x0,y0),(x3, y3)为起点和终点, (x,y)为圆心
  /// 贝塞尔曲线画圆，若分成n等分，则曲线端点到最近控制点的最佳距离为(4/3)*((1-cos(θ/2))/sin(θ/2))*r , θ = 2π/n;
  /// x1 = x0 - (4/3)*((1-cos(θ/2))/sin(θ/2))*(y0-y); (x ,y)为圆心
  /// y1 =y0 + (4/3)*((1-cos(θ/2))/sin(θ/2))*(x0-x)
  /// x2 =x3 + (4/3)*((1-cos(θ/2))/sin(θ/2))*(y3-y)
  /// y2= y3 - (4/3)*((1-cos(θ/2))/sin(θ/2))*(x3-x)
  static getCubicControlPoint(
      {@required x0,
      @required y0,
      @required x3,
      @required y3,
      @required radians,
      @required x,
      @required y}) {
    double h = 4 / 3 * math.tan(radians / 4);
    double x1 = x0 - (h * (y0 - y));
    double y1 = y0 + h * (x0 - x);
    double x2 = x3 + h * (y3 - y);
    double y2 = y3 - (h * (x3 - x));
    return {
      'x1': x1,
      'x2': x2,
      'y1': y1,
      'y2': y2,
    };
  }
}
