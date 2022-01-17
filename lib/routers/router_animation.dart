import 'package:flutter/material.dart';

SlideTransition createTransition(Animation<double> animation, Widget child) {
  return new SlideTransition(
    position: new Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0.0, 0.0),
    ).animate(animation),
    child: child,
  );
}
