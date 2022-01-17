// 关注

import 'package:flutter/material.dart';

class UserFoucsPage extends StatefulWidget {
  UserFoucsPage({Key? key}) : super(key: key);

  @override
  _UserFoucsPageState createState() => _UserFoucsPageState();
}

class _UserFoucsPageState extends State<UserFoucsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('关注'),
        ),
      ),
    );
  }
}
