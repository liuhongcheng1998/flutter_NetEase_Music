// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netease_app/model/ball.dart';
import 'package:netease_app/model/pointHelper.dart';
import 'package:netease_app/model/rotateCircle.dart';

class LonelyPlanet extends StatelessWidget {
  final double size = 240;
  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        CirclePaint(
          size: size,
        ),
      ],
    );
  }
}

class CirclePaint extends StatefulWidget {
  final double size;
  CirclePaint({required this.size});
  @override
  _CirclePaintState createState() => _CirclePaintState();
}

class _CirclePaintState extends State<CirclePaint>
    with TickerProviderStateMixin {
  double get size => widget.size;
  List<RotateCircle> rotateCircles = [];
  late AnimationController _animationController;
  late DateTime _preTime;

  /// 生成rotateCircle间隔
  Duration _interval = Duration(milliseconds: 1000);

  /// 每次更新减少的opacity
  double _opacity = 0.008;

  /// 圈上小球每次的移动
  double _radians = 0.005;

  /// 每次更新圈的半径增加
  double circleR = 0.5;
  @override
  void initState() {
    _preTime = DateTime.now();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 200));
    // TweenSequence
    Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear)
        ..addListener(() {
          updateBalls();
          setState(() {});
        })
        ..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _animationController.repeat();
          }
        }),
    );
    _animationController.forward();
    super.initState();
  }

  updateBalls() {
    /// 去除第一个
    if (rotateCircles.isNotEmpty) {
      var first = rotateCircles.first;
      if (first.opacity <= 0) {
        rotateCircles.remove(first);
      }
    }

    /// 更新
    rotateCircles.forEach((rotateCircle) {
      var opacity = rotateCircle.opacity - _opacity;
      var r = rotateCircle.r + circleR;
      rotateCircle.r = r;
      rotateCircle.opacity = opacity >= 0 ? opacity : 0;
      var ball = rotateCircle.ball;
      var radians = ball.radians - _radians;
      var point = PointHelper.getPoint(r1: size / 2, r: r, angle: radians);
      ball.x = point.x;
      ball.y = point.y;
      ball.radians = radians;
    });

    /// 新增
    var now = DateTime.now();
    if (now.difference(_preTime) > _interval) {
      _preTime = now;
      var r = size / 2;
      var pos = PointHelper.getPoint(r: r, r1: r);
      rotateCircles.add(
        RotateCircle(
          r: size / 2,
          ball: Ball(
            x: pos.x,
            y: pos.y,
            radians: pos.angle,
            r: 5,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: CirclePainter(rotateCircles),
    );
  }
}

class CirclePainter extends CustomPainter {
  final List<RotateCircle> rotateCircles;
  Paint _paint;
  CirclePainter(this.rotateCircles)
      : _paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 2;
  @override
  void paint(Canvas canvas, Size size) {
    rotateCircles.forEach((rotateCircle) {
      var ball = rotateCircle.ball;
      canvas.drawCircle(
          Offset(ball.x, ball.y),
          5,
          _paint
            ..color = Colors.red.withOpacity(rotateCircle.opacity)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(size.width / 2, size.width / 2), rotateCircle.r,
          _paint..style = PaintingStyle.stroke);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
