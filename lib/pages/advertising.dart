// 首屏广告页

import 'dart:async';

import 'package:flutter/material.dart';

class AdvertisingPage extends StatefulWidget {
  AdvertisingPage({Key? key}) : super(key: key);

  @override
  _AdvertisingPageState createState() => _AdvertisingPageState();
}

class _AdvertisingPageState extends State<AdvertisingPage> {
  final String launchImage =
      "https://media.calerie.com/img/images/products/bg_media_files/2021/06/04/4dea403022429dc71729b18b850c7746.jpg"; // 图片地址
  int _countdown = 5; // 倒计时时间
  var _countdownTimer; // 倒计时控制器

  @override
  void initState() {
    super.initState();
    // 初始化需要加载的数据
    _startRecordTime();
  }

  @override
  void dispose() {
    super.dispose();
    // 销毁时需要做的处理
    if (_countdownTimer != null && _countdownTimer.isActive) {
      _countdownTimer.cancel();
    }
  }

  void _startRecordTime() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown <= 1) {
          _countdownTimer.cancel();
          // 倒计时结束去到首页
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        } else {
          _countdown -= 1;
        }
      });
    });
  }

  toIndex() {
    _countdownTimer.cancel();
    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 放一张图片
            Image.asset(
              'images/default/welcome.png',
              fit: BoxFit.fill,
            ),
            // 左上倒计时
            Positioned(
              child: ElevatedButton(
                child: Container(
                  padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: '$_countdown',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          )),
                      TextSpan(
                        text: '跳过',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ]),
                  ),
                ),
                onPressed: () => toIndex(),
              ),
              top: 30,
              right: 30,
            )
          ],
        ),
      ),
    );
  }
}
