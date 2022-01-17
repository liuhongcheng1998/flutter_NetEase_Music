// 这个是视频详情

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/pages/video_page/videoUrlPlay.dart';
import 'package:netease_app/utils/number_utils.dart';
import 'package:netease_app/wight/widget_future_builder.dart';

class VideoDetailWidget extends StatefulWidget {
  String videoId;
  VideoDetailWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoDetailWidgetState createState() =>
      _VideoDetailWidgetState(videoId: this.videoId);
}

class _VideoDetailWidgetState extends State<VideoDetailWidget>
    with SingleTickerProviderStateMixin {
  String videoId;
  List videolist = [];
  String title = '';
  String subtitle = '';
  TabController? _tabController; // 这个是tab栏操作
  _VideoDetailWidgetState({required this.videoId});

  var mvinfo;
  @override
  void initState() {
    super.initState();
    mvinfo = getMvAll();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (videoId != widget.videoId) {
      mvinfo = getMvAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getsimivideolist(context, params) async {
    var data = await getSimiVideo(params);
    if (data["code"] == 200) {
      return data["data"];
    } else {
      return [];
    }
  }

  getMvAll() async {
    var info = await Future.wait([getPlayMvDetail(), getPlayMvUrl()]);
    return info;
  }

  Future getPlayMvUrl() async {
    Map<String, dynamic> params = {
      "id": "$videoId",
    };
    var data = await getVideoUrl(params);
    if (data["code"] == 200) {
      return data["urls"];
    } else {
      return null;
    }
  }

  Future getPlayMvDetail() async {
    Map<String, dynamic> params = {
      "id": "$videoId",
    };
    var data = await getVideoDetail(params);
    if (data["code"] == 200) {
      setState(() {
        subtitle = data["data"]["creator"]["nickname"];
        title = data["data"]["title"];
      });
      return data["data"];
    } else {
      return null;
    }
  }

  createsimimvList() {
    return CustomFutureBuilder(
      futureFunc: _getsimivideolist,
      params: {
        "id": "$videoId",
      },
      loadingWidget: Container(),
      builder: (context, value) {
        print(value);
        value as List;
        return Column(
          children: value.map((element) => createsimiItem(element)).toList(),
        );
      },
    );
  }

  Widget createsimiItem(item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/videoplaylist', arguments: {
          "id": item["vid"],
          "type": 1,
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Container(
              width: 160,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    item["coverUrl"],
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
                children: [
                  Text(
                    '${item["title"]}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item["creator"][0]["userName"]}',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${NumberUtils.amountConversion(item["playTime"])}次',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  createMVdetail(mvdetial) {
    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      mvdetial["avatarUrl"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(mvdetial["creator"]["nickname"])
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(mvdetial["creator"]
                        ["followed"]
                    ? Colors.pink
                    : Color.fromRGBO(247, 116, 155, 1)),
                elevation: MaterialStateProperty.all(0),
                overlayColor:
                    MaterialStateProperty.all(Color.fromRGBO(0, 0, 0, 0.08)),
              ),
              child: Text(
                '${mvdetial["creator"]["followed"] ? '已关注' : '关注'}',
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: mvdetial["title"]),
              ])),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.black54,
              size: 18,
            ),
            Text(
              '${NumberUtils.amountConversion(mvdetial["playTime"])}次观看',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Color.fromRGBO(154, 154, 154, 1),
                ),
                Text(
                  '${NumberUtils.amountConversion(mvdetial["praisedCount"])}',
                  style: TextStyle(
                    color: Color.fromRGBO(154, 154, 154, 1),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.favorite_border_outlined,
                  color: Color.fromRGBO(154, 154, 154, 1),
                ),
                Text(
                  '不喜欢',
                  style: TextStyle(
                    color: Color.fromRGBO(154, 154, 154, 1),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.share_rounded,
                  color: Color.fromRGBO(154, 154, 154, 1),
                ),
                Text(
                  '${NumberUtils.amountConversion(mvdetial["shareCount"])}',
                  style: TextStyle(
                    color: Color.fromRGBO(154, 154, 154, 1),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.library_add_rounded,
                  color: Color.fromRGBO(154, 154, 154, 1),
                ),
                Text(
                  '收藏',
                  style: TextStyle(
                    color: Color.fromRGBO(154, 154, 154, 1),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Icon(
                  Icons.chat_rounded,
                  color: Color.fromRGBO(154, 154, 154, 1),
                ),
                Text(
                  '${NumberUtils.amountConversion(mvdetial["commentCount"])}',
                  style: TextStyle(
                    color: Color.fromRGBO(154, 154, 154, 1),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: mvinfo,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.done:
                return MediaQuery.removePadding(
                    removeTop: Platform.isIOS,
                    context: context,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: Platform.isIOS
                                ? 46
                                : 0 + MediaQuery.of(context).padding.top,
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top),
                            decoration: BoxDecoration(
                              color: Colors.black,
                            ),
                          ),
                          VideoPlayUrlWigdet(
                            title: title,
                            mvurl: snapshot.data[1][0]["url"]
                                .replaceFirst('http', 'https'),
                          ),
                          Container(
                            height: 40,
                            width: double.infinity,
                            // color: Colors.black,
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 12.0),
                            // margin: EdgeInsets.only(bottom: 20),
                            alignment: Alignment.centerLeft,
                            child: TabBar(
                              isScrollable: true,
                              tabs: [
                                Text('详情'),
                                Text('评论'),
                              ],
                              controller: _tabController,
                              indicatorColor: Colors.black,
                              indicatorWeight: 3,
                              unselectedLabelColor: Colors.grey,
                              labelColor: Color.fromRGBO(0, 0, 0, 0.87),
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                ListView(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 0, bottom: 0),
                                  children: [
                                    // 第一部分是mv详情
                                    Container(
                                      child: createMVdetail(snapshot.data[0]),
                                    ),
                                    // 第二部分是相似mv
                                    createsimimvList(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  children: [Text('评论')],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));

              case ConnectionState.waiting:
              case ConnectionState.none:
              default:
                return Container();
            }
          },
        ),
      ),
      value: SystemUiOverlayStyle.light,
    );
  }
}
