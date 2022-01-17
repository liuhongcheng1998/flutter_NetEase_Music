// 搜索视频列表

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:netease_app/http/request.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends StatefulWidget {
  String searchvalue;
  VideoPlayerWidget({Key? key, this.searchvalue = ''}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() =>
      _VideoPlayerWidgetState(searchvalue: this.searchvalue);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  String searchvalue;
  List searchResult = [];
  bool ismore = false; // 是否还有更多
  int _offset = 0; // 偏移量
  late EasyRefreshController _controller;
  _VideoPlayerWidgetState({this.searchvalue = ''});
  Future _getSearchResult({String limit = '30', int offset = 0}) async {
    var params = {
      "keywords": searchvalue,
      "type": "1014",
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
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  filtterTimer(int timer) {
    return DateUtil.formatDateMs(timer, format: 'mm:ss');
  }

  createCreator(List list) {
    List showList = list.map((item) {
      return item["userName"];
    }).toList();
    return showList.join('/');
  }

  computePlayCount(int playcout) {
    if (playcout > 10000) {
      return (playcout / 10000).toStringAsFixed(1) + '万';
    } else {
      return playcout.toString();
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(bottom: 60),
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
                searchResult.addAll(res["videos"]);
              });
              if (res["videoCount"] != searchResult.length) {
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
                searchResult.addAll(res["videos"]);
              });
              if (res["videoCount"] != searchResult.length) {
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
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/videoplaylist', arguments: {
                  "id": item["vid"],
                  "type": item["type"],
                });
              },
              child: Container(
                height: 90,
                padding: EdgeInsets.only(left: 16, right: 16),
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      height: 90,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              '${item["coverUrl"]}?param=150y90',
                              fit: BoxFit.cover,
                              width: 150,
                              height: 90,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 8,
                            child: Text(
                              filtterTimer(item["durationms"]),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SubstringHighlight(
                            text: item["title"],
                            term: searchvalue,
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textStyleHighlight: TextStyle(
                              // highlight style
                              color: Color.fromRGBO(66, 125, 172, 1),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SubstringHighlight(
                                text: createCreator(item["creator"]),
                                term: searchvalue,
                                textStyle: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textStyleHighlight: TextStyle(
                                  // highlight style
                                  color: Color.fromRGBO(66, 125, 172, 1),
                                ),
                              ),
                              Text(
                                '${computePlayCount(item["playTime"])}次',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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
