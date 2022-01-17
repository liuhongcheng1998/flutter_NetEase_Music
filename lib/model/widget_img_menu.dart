import 'package:flutter/material.dart';

class ImageMenuWidget extends StatelessWidget {
  final String img;
  final double size;
  final VoidCallback onTap;

  ImageMenuWidget(this.img, this.size, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          img,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
