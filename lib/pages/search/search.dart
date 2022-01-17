// 搜索页

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/components/search/searchAppBar.dart';
import 'package:netease_app/components/search/searchTips.dart';
import 'package:netease_app/http/request.dart';

class SearchPage extends StatefulWidget {
  final String searchTip;
  final List searchTips;
  SearchPage({Key? key, required this.searchTip, required this.searchTips})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState(
        searchTip: this.searchTip,
        searchTips: this.searchTips,
      );
}

class _SearchPageState extends State<SearchPage> {
  final String searchTip; // 搜索提示
  final List searchTips; // 推荐搜索列表
  late var hotdetaillist;
  int switchIndex = 0; // 这个是显示索引
  String searchValue = '';
  _SearchPageState({required this.searchTip, required this.searchTips});

  @override
  void initState() {
    super.initState();
    hotdetaillist = _gethotdetail();
  }

  Future _gethotdetail() async {
    var data = await getHotSearchDetail();

    if (data["code"] == 200) {
      return data["data"];
    } else {
      return [];
    }
  }

  _createHistoryItem(item) {
    // 创建历史搜索item
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 246, 246, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  _createHotList(List? hotlist) {
    List<Widget> rightWidget = <Widget>[];
    List<Widget> leftWidget = <Widget>[];
    List.generate(hotlist!.length, (index) {
      if (index % 2 == 0) {
        leftWidget.add(Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              // 下标
              SizedBox(
                width: 20,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index <= 2
                        ? Colors.red
                        : Color.fromRGBO(151, 151, 151, 1),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                hotlist[index]["searchWord"],
                style: TextStyle(
                  color: index <= 2 ? Colors.black87 : Colors.black54,
                  // fontWeight: index <= 2 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ));
      } else {
        rightWidget.add(Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              // 下标
              SizedBox(
                width: 20,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index <= 2
                        ? Colors.red
                        : Color.fromRGBO(151, 151, 151, 1),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                hotlist[index]["searchWord"],
                style: TextStyle(
                  color: index <= 2 ? Colors.black87 : Colors.black54,
                  // fontWeight: index <= 2 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ));
      }
    });

    return [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: leftWidget,
        ),
        flex: 1,
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: rightWidget,
        ),
        flex: 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0,
        backgroundColor: Colors.white,
        title: SearchAppBar(
          key: globalKey,
          hintLabel: searchTip,
          focusback: () {},
          callbackvalue: (value) {
            if (value.isEmpty) {
              setState(() {
                switchIndex = 0;
              });
            } else {
              setState(() {
                switchIndex = 1;
              });
            }
            setState(() {
              searchValue = value;
            });
          },
          submitcallback: (value) {
            String searchSubValue = value.isNotEmpty ? value : searchTip;
            Navigator.of(context)
                .pushNamed('/searchresult', arguments: searchSubValue)
                .then((res) {
              if (res != null) {
                if (res is Map) {
                  if (res["name"] == 'searchreslut') {
                    // 如果到这里的话说明是在搜索结果页点击了搜索输入框
                    // 需要告诉主页面聚焦并且将输入框的值改为传过来的值
                    globalKey.currentState!.setValue(res["value"]);
                    globalKey.currentState!.setFoucs();
                  }
                }
              } else {
                globalKey.currentState!.clearValue();
                setState(() {
                  switchIndex = 0;
                });
              }
            });
          },
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: GestureDetector(
        onVerticalDragDown: (detail) {
          globalKey.currentState!.moveFoucs();
        },
        child: IndexedStack(
          index: switchIndex,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 0),
                  child: ListView(
                    children: [
                      // 广告
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'images/default/search_banner.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // 历史搜索
                      Container(
                        width: double.infinity,
                        height: 30,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Center(
                                child: Text(
                                  '历史',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                children: [
                                  _createHistoryItem('刘德华'),
                                  _createHistoryItem('删了吧'),
                                  _createHistoryItem('张杰'),
                                  _createHistoryItem('last dance'),
                                  _createHistoryItem('情非得已'),
                                  _createHistoryItem('你不知道的事'),
                                ],
                              ),
                              flex: 1,
                            ),
                            GestureDetector(
                              onTap: () {
                                // 删除历史记录
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Icon(Icons.delete_outline_rounded),
                              ),
                            )
                          ],
                        ),
                      ),
                      // 推荐搜索
                      Container(
                        margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                        width: double.infinity,
                        height: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 20,
                              child: Text(
                                '推荐搜索:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      height: 20,
                                      margin: EdgeInsets.only(right: 10),
                                      child: Text(
                                        searchTips[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color.fromRGBO(103, 121, 155, 1),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: searchTips.length,
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                      ),
                      // 热搜榜
                      Container(
                        child: Text(
                          '热搜榜',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      FutureBuilder(
                        future: hotdetaillist,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              width: double.infinity,
                              height: 200,
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text('获取失败!'),
                                ),
                              ),
                            );
                          }
                          switch (snapshot.connectionState) {
                            case ConnectionState.active:
                            case ConnectionState.done:
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: _createHotList(snapshot.data),
                                    ),
                                  ),
                                ),
                              );
                            case ConnectionState.waiting:
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                height: 200,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      child: LoadingIndicator(
                                        indicatorType: Indicator.lineScale,
                                        colors: const [Colors.red],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            case ConnectionState.none:
                            default:
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                height: 200,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text('获取失败!'),
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                      // 音乐专区
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(
                          '音乐专区',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0, 1],
                                    colors: [
                                      Color.fromRGBO(131, 121, 112, 1),
                                      Color.fromRGBO(220, 206, 197, 1)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '歌手分类',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      width: 70,
                                      height: 32,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  'images/default/search_avator1.jpg',
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            right: 30,
                                          ),
                                          Positioned(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  'images/default/search_avator2.jpg',
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            right: 15,
                                          ),
                                          Positioned(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.asset(
                                                  'images/default/search_avator3.jpg',
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            right: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              flex: 1,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0, 1],
                                    colors: [
                                      Color.fromRGBO(232, 79, 65, 1),
                                      Color.fromRGBO(243, 174, 166, 1)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '曲风分类',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Image.asset(
                                      'images/default/search_song.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  ],
                                ),
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 60,
                      )
                    ],
                  ),
                ),
                FadeInUp(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ButtonPlayWight(),
                  ),
                ),
              ],
            ),
            SearchTipsWigdet(
              searchValue: searchValue,
              callbackvalue: (value) {
                globalKey.currentState!.clearValue();
                setState(() {
                  switchIndex = 0;
                });
              },
              changefocus: (value) {
                globalKey.currentState!.setValue(value);
                globalKey.currentState!.setFoucs();
                setState(() {
                  switchIndex = 1;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
