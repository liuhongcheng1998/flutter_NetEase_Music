// 搜索 单曲

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:netease_app/style/textstyle.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class SearchSingleWidget extends StatefulWidget {
  String searchvalue;
  SearchSingleWidget({Key? key, this.searchvalue = ''}) : super(key: key);

  @override
  _SearchSingleWidgetState createState() =>
      _SearchSingleWidgetState(searchvalue: this.searchvalue);
}

class _SearchSingleWidgetState extends State<SearchSingleWidget>
    with AutomaticKeepAliveClientMixin {
  String searchvalue;
  List searchResult = [];
  bool ismore = false; // 是否还有更多
  int _offset = 0; // 偏移量
  late EasyRefreshController _controller;
  _SearchSingleWidgetState({this.searchvalue = ''});

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  Future _getSearchResult({String limit = '30', int offset = 0}) async {
    var params = {
      "keywords": searchvalue,
      "type": "1",
    };
    params["limit"] = limit;
    params["offset"] = '$offset';
    var data = await searchValueResultDet(params);
    if (data["code"] == 200) {
      return data["result"];
    } else {
      return null;
    }
  }

  createArtistString(List list) {
    List artistString = [];
    list.forEach((element) {
      artistString.add(element["name"]);
    });
    return artistString.join('/');
  }

  createrightaction(item) {
    return Container(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          createismvicon(item["mv"]),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              print('菜单');
            },
            child: Icon(
              Icons.more_vert,
              color: Color.fromRGBO(181, 181, 181, 1),
            ),
          ),
        ],
      ),
    );
  }

  createismvicon(int mvid) {
    if (mvid != 0) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          print('音乐视频');
        },
        child: Icon(
          Icons.smart_display,
          color: Color.fromRGBO(181, 181, 181, 1),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  createartists(List list, item) {
    String text = '';
    list.forEach((element) {
      text += "${element["name"]}/";
    });
    text = text.substring(0, text.length - 1);
    text += ' - ${item["al"]["name"]}';
    List<Widget> istag = [];
    if (item["originCoverType"] == 1) {
      // 表明是原唱
      istag.add(Container(
        padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
        margin: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.red,
        ),
        child: Text(
          '原唱',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ));
    }

    istag.add(Expanded(
      child: SubstringHighlight(
        text: text,
        term: searchvalue,
        textStyle: songsubtitle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textStyleHighlight: TextStyle(
          // highlight style
          color: Color.fromRGBO(66, 125, 172, 1),
        ),
      ),
      flex: 1,
    ));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: istag,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = getIt<PageManager>();
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(bottom: 60),
      child: EasyRefresh(
          controller: _controller,
          firstRefresh: true,
          firstRefreshWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                width: 20,
                height: 20,
                child: LoadingIndicator(
                  indicatorType: Indicator.lineScalePulseOut,
                  colors: const [Colors.red],
                ),
              ),
              Text('加载中...')
            ],
          ),
          emptyWidget: searchResult.isEmpty
              ? Container(
                  margin: EdgeInsets.only(top: 30),
                  width: double.infinity,
                  height: 100,
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
                )
              : null,
          onRefresh: () async {
            setState(() {
              _offset = 0;
            });
            _getSearchResult(limit: "30", offset: _offset).then((res) {
              setState(() {
                searchResult = [];
              });
              if (res != null) {
                setState(() {
                  searchResult.addAll(res["songs"]);
                });
                if (res["songCount"] != searchResult.length) {
                  _controller.finishLoad(noMore: false);
                  setState(() {
                    _offset++;
                  });
                } else {
                  _controller.finishLoad(noMore: true);
                }
                _controller.finishRefresh(success: true);
              } else {
                setState(() {
                  searchResult = [];
                });
              }
            }).catchError((e) {});
            _controller.resetLoadState();
          },
          header: DeliveryHeader(
            backgroundColor: Colors.black,
          ),
          footer: BallPulseFooter(
            color: Colors.red,
          ),
          onLoad: () async {
            _getSearchResult(limit: "30", offset: _offset * 30).then((res) {
              if (res != null) {
                setState(() {
                  searchResult.addAll(res["songs"]);
                });
                if (res["songCount"] != searchResult.length) {
                  _controller.finishLoad(noMore: false, success: true);
                  setState(() {
                    _offset++;
                  });
                } else {
                  _controller.finishLoad(noMore: true, success: true);
                }
              } else {
                setState(() {
                  searchResult = [];
                });
              }
            }).catchError((e) {});
          },
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                              width: 0.5, color: Color.fromRGBO(0, 0, 0, 0.18)),
                        )),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 添加到播放列表并修改当前的index    final model = getIt<PageManager>();
                            List<Song> playsongslist = <Song>[];
                            searchResult.forEach((element) {
                              playsongslist.add(Song(
                                element["id"],
                                Duration(milliseconds: element["dt"]),
                                name: element["name"],
                                picUrl: element["al"]["picUrl"],
                                artists: createArtistString(element["ar"]),
                              ));
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle,
                                color: Colors.red,
                                size: 24,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '播放全部',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(
                                        width: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var item = searchResult[index];
                  return ValueListenableBuilder<List>(
                    valueListenable: model.playlistNotifier,
                    builder: (context, allpalylist, child) {
                      return ValueListenableBuilder<MediaItem>(
                        valueListenable: model.currentSongTitleNotifier,
                        builder: (context, value, child) {
                          bool ispaly = false;
                          if (item["id"].toString() == value.id) {
                            ispaly = true;
                          }
                          return GestureDetector(
                            onTap: () async {
                              // 将该歌曲添加到播放列表
                              int index = allpalylist.indexWhere((element) =>
                                  element.id == item["id"].toString());
                              if (index > 0) {
                                model.playInex(index);
                              } else {
                                await model.add(Song(
                                  item["id"],
                                  Duration(microseconds: item["dt"]),
                                  artists: createArtistString(item["ar"]),
                                  picUrl: item["al"]["picUrl"],
                                  name: item["name"],
                                ));
                                await model.play();
                              }
                            },
                            child: Container(
                              height: 55,
                              padding: EdgeInsets.only(left: 16, right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ispaly
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          margin: EdgeInsets.only(right: 5),
                                          child: LoadingIndicator(
                                            indicatorType:
                                                Indicator.lineScaleParty,
                                            colors: const [Colors.red],
                                          ),
                                        )
                                      : SizedBox(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SubstringHighlight(
                                          text: item["name"],
                                          term: searchvalue,
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textStyleHighlight: TextStyle(
                                            // highlight style
                                            color:
                                                Color.fromRGBO(66, 125, 172, 1),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        createartists(item["ar"], item),
                                      ],
                                    ),
                                    flex: 1,
                                  ),
                                  createrightaction(item),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }, childCount: searchResult.length),
              ),
            ],
          )),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
