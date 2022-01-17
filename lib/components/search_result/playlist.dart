// 歌单搜索页

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/style/textstyle.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class PlayListWidget extends StatefulWidget {
  String searchvalue;
  PlayListWidget({Key? key, this.searchvalue = ''}) : super(key: key);
  @override
  _PlayListWidgetState createState() =>
      _PlayListWidgetState(searchvalue: this.searchvalue);
}

class _PlayListWidgetState extends State<PlayListWidget>
    with AutomaticKeepAliveClientMixin {
  String searchvalue;
  List searchResult = [];
  bool ismore = false; // 是否还有更多
  int _offset = 0; // 偏移量
  late EasyRefreshController _controller;
  _PlayListWidgetState({this.searchvalue = ''});
  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  Future _getSearchResult({String limit = '30', int offset = 0}) async {
    var params = {
      "keywords": searchvalue,
      "type": "1000",
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

  @override
  bool get wantKeepAlive => true;

  computePlayCount(int playcout) {
    if (playcout > 10000) {
      print((playcout / 10000).toStringAsFixed(1) + '万');
      return (playcout / 10000).toStringAsFixed(1) + '万';
    } else {
      print(playcout.toString());
      return playcout.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(bottom: 60),
      child: EasyRefresh(
        controller: _controller,
        enableControlFinishRefresh: true,
        firstRefresh: true,
        enableControlFinishLoad: true,
        footer: BallPulseFooter(
          color: Colors.red,
        ),
        header: DeliveryHeader(
          backgroundColor: Colors.blue,
        ),
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
                searchResult.addAll(res["playlists"]);
              });
              if (res["playlistCount"] != searchResult.length) {
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
        onLoad: () async {
          _getSearchResult(limit: "30", offset: _offset * 30).then((res) {
            if (res != null) {
              setState(() {
                searchResult.addAll(res["playlists"]);
              });
              if (res["playlistCount"] != searchResult.length) {
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
        child: ListView.builder(
          itemBuilder: (context, index) {
            var item = searchResult[index];
            List<Widget> istag = <Widget>[];
            if (item["officialTags"] != null) {
              if (item["officialTags"].isNotEmpty) {
                item["officialTags"].forEach((element) {
                  istag.add(
                    Container(
                      padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      margin: EdgeInsets.only(right: 5),
                      color: Color.fromRGBO(255, 249, 228, 1),
                      child: Text(
                        element,
                        style: TextStyle(
                          color: Color.fromRGBO(221, 137, 103, 1),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                });
              }
            }
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/playlist', arguments: item["id"]);
              },
              child: Container(
                height: 60,
                padding: EdgeInsets.only(left: 16, right: 16),
                margin: EdgeInsets.only(bottom: 10, top: index == 0 ? 10 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '${item["coverImgUrl"]}?param=100y100',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            SubstringHighlight(
                              text: item["name"],
                              term: searchvalue,
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textStyleHighlight: TextStyle(
                                // highlight style
                                color: Color.fromRGBO(66, 125, 172, 1),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${item["trackCount"]}首音乐 ',
                                  style: songsubtitle,
                                ),
                                Container(
                                  width: 50,
                                  child: Text(
                                    "by ${item["creator"]["nickname"]} ,  ",
                                    style: songsubtitle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  "播放${computePlayCount(item["playCount"])}次",
                                  style: songsubtitle,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            istag.isEmpty
                                ? SizedBox()
                                : Row(
                                    children: istag,
                                  ),
                          ],
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: searchResult.length,
        ),
      ),
    );
  }
}
