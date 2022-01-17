// 斗鱼直播筛选页

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/pages/live/live_screen_result.dart';

class LiveScreenTypePgae extends StatefulWidget {
  LiveScreenTypePgae({Key? key}) : super(key: key);

  @override
  _LiveScreenTypePgaeState createState() => _LiveScreenTypePgaeState();
}

class _LiveScreenTypePgaeState extends State<LiveScreenTypePgae>
    with SingleTickerProviderStateMixin {
  TabController? _tabController; // 这个是tab栏操作
  var tabinfo;

  @override
  void initState() {
    super.initState();
    tabinfo = _getdyColumList(); // 获取大type
  }

  _getdyColumList() async {
    var data = await getdouyuBigType();
    if (data["error"] == 0) {
      _tabController = TabController(length: data["data"].length, vsync: this);
      return data["data"];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '直播分类',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: FutureBuilder(
            future: tabinfo,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.done:
                  List _tablist = snapshot.data;
                  if (_tablist.isNotEmpty) {
                    return Theme(
                      data: ThemeData(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      child: TabBar(
                        unselectedLabelColor: Colors.black54, // 未选中颜色
                        indicatorColor:
                            Color.fromRGBO(235, 102, 96, 1), // 选中下划线颜色
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 0,
                          bottom: 0,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 5,
                        indicator: BubbleTabIndicator(
                          indicatorHeight: 5,
                          indicatorColor: Color.fromRGBO(235, 102, 96, 1),
                          tabBarIndicatorSize: TabBarIndicatorSize.tab,
                          insets: EdgeInsets.only(top: 10),
                        ),
                        labelColor: Colors.black,
                        controller: _tabController,
                        isScrollable: true,
                        tabs:
                            _tablist.map((e) => Text(e["cate_name"])).toList(),
                        onTap: (value) {},
                      ),
                    );
                  } else {
                    return Container();
                  }
                case ConnectionState.waiting:
                case ConnectionState.none:
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder(
          future: tabinfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.done:
                List _tablist = snapshot.data;
                if (_tablist.isNotEmpty) {
                  return TabBarView(
                    children: _tablist
                        .map((e) => LiveScreenResultWidget(
                              name: e["short_name"],
                            ))
                        .toList(),
                    controller: _tabController,
                  );
                } else {
                  return Container();
                }
              case ConnectionState.waiting:
              case ConnectionState.none:
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
