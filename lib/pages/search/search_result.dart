// 搜索结果

import 'package:animate_do/animate_do.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/components/search/searchAppBar.dart';
import 'package:netease_app/components/search_result/album.dart';
import 'package:netease_app/components/search_result/comprehensive.dart';
import 'package:netease_app/components/search_result/playlist.dart';
import 'package:netease_app/components/search_result/singer.dart';
import 'package:netease_app/components/search_result/single.dart';
import 'package:netease_app/components/search_result/user.dart';
import 'package:netease_app/components/search_result/videoPlayer.dart';

class Choice {
  const Choice({required this.title, required this.value});
  final String title;
  final String value;
}

// ignore: must_be_immutable
class SearchResultPage extends StatefulWidget {
  String searchValue;
  SearchResultPage({Key? key, required this.searchValue}) : super(key: key);

  @override
  _SearchResultPageState createState() =>
      _SearchResultPageState(searchValue: this.searchValue);
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  String searchValue;
  List<Choice> tabsList = [
    Choice(title: "综合", value: "1018"),
    Choice(title: "单曲", value: "1"),
    Choice(title: "歌单", value: "1000"),
    Choice(title: "视频", value: "1014"),
    Choice(title: "歌手", value: "100"),
    Choice(title: "专辑", value: "10"),
    Choice(title: "用户", value: "1002"),
  ];
  late TabController _tabController;
  _SearchResultPageState({required this.searchValue});

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabsList.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: SearchAppBar(
            hintLabel: '',
            callbackvalue: (value) {},
            value: searchValue,
            submitcallback: (value) {},
            focusback: () {
              Navigator.of(context).pop({
                "name": "searchreslut",
                "value": searchValue,
              });
            },
            autofoucs: false,
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size(0, 30),
            child: Theme(
              child: TabBar(
                unselectedLabelColor: Colors.black54, // 未选中颜色
                indicatorColor: Color.fromRGBO(235, 102, 96, 1), // 选中下划线颜色
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
                tabs: tabsList.map((Choice e) {
                  return Tab(
                    height: 30,
                    text: e.title,
                  );
                }).toList(),
              ),
              data: ThemeData(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // 综合搜索
                ComprehensiveWidget(
                  searchvalue: searchValue,
                ),
                SearchSingleWidget(
                  searchvalue: searchValue,
                ),
                PlayListWidget(
                  searchvalue: searchValue,
                ),
                VideoPlayerWidget(
                  searchvalue: searchValue,
                ),
                SingerWidget(
                  searchvalue: searchValue,
                ),
                AlbumWidget(
                  searchvalue: searchValue,
                ),
                SearchUserWidget(
                  searchvalue: searchValue,
                ),
              ],
            ),
            FadeInUp(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ButtonPlayWight(),
              ),
            ),
          ],
        ));
  }
}
