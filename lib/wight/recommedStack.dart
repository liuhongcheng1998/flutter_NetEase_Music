import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_app/wight/playPaint.dart';

class RecommendStackWidget extends StatefulWidget {
  double opacity;
  RecommendStackWidget({Key? key, required this.opacity}) : super(key: key);

  @override
  _RecommendStackWidgetState createState() =>
      _RecommendStackWidgetState(opacity: this.opacity);
}

class _RecommendStackWidgetState extends State<RecommendStackWidget> {
  double opacity;
  _RecommendStackWidgetState({required this.opacity});

  @override
  void didUpdateWidget(covariant RecommendStackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.setState(() {
      opacity = widget.opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  ExactAssetImage('images/default/recommend_banner.jpg'), //背景图片
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            // make sure we apply clip it properly
            child: BackdropFilter(
              //背景滤镜
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), //背景模糊化
              child: Container(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            child: CustomPaint(
              painter: Sky(),
            ),
          ),
        ),
        Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 100,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.only(left: 15, right: 15),
              // color: Colors.orange,
              child: Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${DateTime.now().day}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                              ),
                            ),
                            TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${DateTime.now().month.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  )
                ],
              ),
            ))
      ],
    );
  }
}
