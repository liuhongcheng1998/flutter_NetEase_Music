// 存放各类盒子的样式

import 'package:flutter/material.dart';

final tipsTitleStyle = TextStyle(fontSize: 12, color: Colors.black38);
final defaultContainerborderRadius = BoxDecoration(
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      blurRadius: 10,
      spreadRadius: 1,
      color: Colors.black12,
    )
  ],
  borderRadius: BorderRadius.circular(10),
);

final songsubtitle = TextStyle(fontSize: 12, color: Colors.black38);
final smallWhite30TextStyle = TextStyle(fontSize: 12, color: Colors.white30);
final smallWhiteTextStyle = TextStyle(fontSize: 12, color: Colors.white);
final commonGrayTextStyle = TextStyle(fontSize: 16, color: Colors.grey);
final commonWhiteTextStyle = TextStyle(fontSize: 16, color: Colors.white);
final commonWhite70TextStyle = TextStyle(fontSize: 16, color: Colors.white70);
final smallGrayTextStyle = TextStyle(fontSize: 12, color: Colors.grey);
