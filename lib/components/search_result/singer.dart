// 搜索歌手

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/http/request.dart';
import 'package:substring_highlight/substring_highlight.dart';

// ignore: must_be_immutable
class SingerWidget extends StatefulWidget {
  String searchvalue;
  SingerWidget({Key? key, this.searchvalue = ''}) : super(key: key);

  @override
  _SingerWidgetState createState() =>
      _SingerWidgetState(searchvalue: this.searchvalue);
}

class _SingerWidgetState extends State<SingerWidget>
    with AutomaticKeepAliveClientMixin {
  String searchvalue;
  List searchResult = [];
  bool ismore = false; // 是否还有更多
  int _offset = 0; // 偏移量
  late EasyRefreshController _controller;
  _SingerWidgetState({this.searchvalue = ''});
  Future _getSearchResult({String limit = '30', int offset = 0}) async {
    var params = {
      "keywords": searchvalue,
      "type": "100",
    };
    params["limit"] = limit;
    params["offset"] = '$offset';
    var data = await searchValueResult(params);
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(bottom: 60),
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
          firstRefreshWidget: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                width: 20,
                height: 20,
                child: LoadingIndicator(
                  indicatorType: Indicator.lineScale,
                  colors: const [Colors.red],
                ),
              ),
            ],
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
                  searchResult.addAll(res["artists"]);
                });
                if (res["artistCount"] != searchResult.length) {
                  _controller.finishLoad(noMore: false);
                  setState(() {
                    _offset++;
                  });
                } else {
                  print('触发没有');
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
                  searchResult.addAll(res["artists"]);
                });
                if (res["artistCount"] != searchResult.length) {
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
                child: Container(
                  height: 60,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  margin: EdgeInsets.only(bottom: 10, top: index == 0 ? 10 : 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.network(
                                  '${item["picUrl"]}?param=100y100',
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
                                    SubstringHighlight(
                                      text: item["name"],
                                      term: searchvalue,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      textStyleHighlight: TextStyle(
                                        // highlight style
                                        color: Color.fromRGBO(66, 125, 172, 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        flex: 1,
                      ),
                      Container(
                        width: 50,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color:
                                item["followed"] ? Colors.black38 : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item["followed"] ? Icons.check : Icons.add,
                              size: 12,
                              color: item["followed"]
                                  ? Colors.black38
                                  : Colors.red,
                            ),
                            Text(
                              '${item["followed"] ? '已关注' : '关注'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: item["followed"]
                                    ? Colors.black38
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: searchResult.length,
          ),
        ),
      ),
    );
  }
}
