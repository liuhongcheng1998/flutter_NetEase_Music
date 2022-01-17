import 'package:flutter/material.dart';
import 'package:netease_app/components/index/indexdraw.dart';
import 'package:netease_app/pages/index/all_live.dart';
import 'package:netease_app/pages/index/cloud_village.dart';
import 'package:netease_app/pages/index/find_musci.dart';
import 'package:netease_app/pages/index/focus.dart';
import 'package:netease_app/pages/index/my_index.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';

class NavigationButtonPage extends StatefulWidget {
  final index;
  NavigationButtonPage({Key? key, this.index = 0}) : super(key: key);

  @override
  _NavigationButtonPageState createState() =>
      _NavigationButtonPageState(this.index);
}

class _NavigationButtonPageState extends State<NavigationButtonPage> {
  late int _currentIndex; // 设置底部导航选中的组件

  _NavigationButtonPageState(index) {
    this._currentIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProsteIndexedStack(
        index: _currentIndex,
        children: [
          IndexedStackChild(
            child: FindMusicPage(),
            preload: true,
          ),
          // IndexedStackChild(
          //   child: LiveAllPage(),
          //   preload: true,
          // ),
          IndexedStackChild(
            child: MyIndexPage(),
          ),
          IndexedStackChild(
            child: UserFoucsPage(),
          ),
          IndexedStackChild(
            child: CloudVillagePage(),
          ),
        ],
        // 根据index做切换页面的显示
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          brightness: Brightness.light,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          selectedFontSize: 12,
          unselectedItemColor: Color.fromRGBO(0, 0, 0, 0.18),
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: '发现',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.live_tv_rounded),
            //   label: '直播',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '我的',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '关注',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '云村',
            ),
          ],
          onTap: (value) {
            setState(() {
              this._currentIndex = value;
            });
          },
        ),
      ),
      drawer: UserLeftDrawPage(),
    );
  }
}
