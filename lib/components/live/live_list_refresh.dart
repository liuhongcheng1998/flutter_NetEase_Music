// 列表页

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:netease_app/http/request.dart';

class LiveListFreshWidget extends StatefulWidget {
  final String url;
  LiveListFreshWidget({Key? key, required this.url}) : super(key: key);

  @override
  _LiveListFreshWidgetState createState() =>
      _LiveListFreshWidgetState(url: this.url);
}

class _LiveListFreshWidgetState extends State<LiveListFreshWidget> {
  String url;
  List liveList = [];
  int _offset = 1; // 偏移量
  late EasyRefreshController _controller;
  _LiveListFreshWidgetState({required this.url});

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.setState(() {
      url = widget.url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        firstRefresh: true,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: true,
        controller: _controller,
        header: DeliveryHeader(
          backgroundColor: Colors.blue,
        ),
        footer: BallPulseFooter(
          color: Colors.red,
        ),
        onRefresh: () async {
          setState(() {
            liveList = [];
            _offset = 1;
          });
          Map<String, dynamic> params = {"limit": "20", "offset": "0"};
          String id = '';
          if (url.isNotEmpty) id = url;
          getdouyuAllList(params, id: id).then((value) {
            if (value["error"] == 0) {
              this.setState(() {
                liveList = value["data"];
              });
              _controller.finishRefresh(success: true);
            } else {
              _controller.finishRefresh(success: false);
            }
          });
          _controller.resetLoadState();
        },
        onLoad: () async {
          Map<String, dynamic> params = {
            "limit": "20",
            "offset": "${_offset * 20}"
          };
          String id = '';
          if (url.isNotEmpty) id = url;
          getdouyuAllList(params, id: id).then((value) {
            if (value["error"] == 0) {
              this.setState(() {
                liveList.addAll(value["data"]);
              });
              if (value["data"].length == 0) {
                _controller.finishLoad(noMore: true, success: true);
              } else {
                _controller.finishLoad(noMore: false, success: true);
                setState(() {
                  _offset++;
                });
              }
            } else {
              _controller.finishLoad(noMore: true, success: true);
            }
          });
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/liveroom', arguments: {
                  "url": liveList[index]["room_id"],
                  "title": liveList[index]["room_name"],
                  "liveType": url,
                  "cover": liveList[index]["room_src"],
                });
              },
              child: Container(
                width: double.infinity,
                height: 90,
                padding: EdgeInsets.only(left: 16, right: 16),
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 160,
                      height: 90,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: liveList[index]["room_src"],
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        progressIndicatorBuilder: (context, url,
                                downloadProgress) =>
                            Image.asset('images/default/playlistdefault.png'),
                        errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'images/default/recommend_banner.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            liveList[index]['room_name'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                liveList[index]['nickname'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: liveList[index]['game_name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(
                                        width: 10,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '热度${liveList[index]['online']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                      ),
                                    )
                                  ],
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
          itemCount: liveList.length,
        ));
  }
}
