import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/utils/number_utils.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SongCommentPage extends StatefulWidget {
  final MediaItem songInfo;
  SongCommentPage({Key? key, required this.songInfo}) : super(key: key);

  @override
  _SongCommentPageState createState() =>
      _SongCommentPageState(songInfo: this.songInfo);
}

class _SongCommentPageState extends State<SongCommentPage> {
  int count = 0;
  int currPage = 1;
  int sortTpye = 1;
  late int songId;

  final MediaItem songInfo;
  late EasyRefreshController _controller;
  List commentList = [];
  bool hasmore = true;
  bool firstrefresh = true;
  _SongCommentPageState({required this.songInfo});

  @override
  void initState() {
    super.initState();
    // songId = int.parse(songInfo.id);
    _controller = EasyRefreshController();
    WidgetsBinding.instance?.addPostFrameCallback((d) async {
      _getFirstList({
        "id": songInfo.id,
        "type": "0",
        "sortType": '$sortTpye',
      });
      // _getCommentList({
      //   "id": songInfo.id,
      //   "type": "0",
      //   "sortType": '$sortTpye',
      // }).then((value) {
      //   if (value != null) {
      //     this.setState(() {
      //       commentList = value["comments"];
      //       hasmore = value["hasMore"];
      //       firstrefresh = false;
      //     });
      //   }
      // });
    });
  }

  _getFirstList(params) async {
    _getCommentList({
      "id": songInfo.id,
      "type": "0",
      "sortType": '$sortTpye',
    }).then((value) {
      if (value != null) {
        this.setState(() {
          commentList = value["comments"];
          hasmore = value["hasMore"];
          firstrefresh = false;
        });
      }
    });
  }

  Future _getCommentList(params) async {
    var data = await getSongsComment(params);
    print(data);
    if (data["code"] == 200) {
      if (count != data["data"]["totalCount"]) {
        this.setState(() {
          count = data["data"]["totalCount"];
        });
      }
      return data["data"];
    } else {
      return null;
    }
  }

  buildHead() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.black,
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                songInfo.extras!['picUrl'],
                width: 30,
                height: 30,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  songInfo.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  ' - ',
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                ),
                Text(
                  '${songInfo.artist}',
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildCommentWidget(item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 35,
          width: 35,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.network(
              item["user"]["avatarUrl"],
              width: 35,
              height: 35,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息
              Row(
                children: [
                  Text(
                    item["user"]["nickname"],
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      '${NumberUtils.amountConversion(item["likedCount"])}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    'images/default/icon_parise.png',
                    width: 17,
                    height: 17,
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              // 时间
              Text(
                item["timeStr"],
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              // 评论内容
              SizedBox(
                height: 10,
              ),
              Text(
                item["content"],
                style:
                    TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text(
          '评论${count != 0 ? '($count)' : ''}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        child: EasyRefresh(
            enableControlFinishRefresh: false,
            enableControlFinishLoad: true,
            controller: _controller,
            footer: BallPulseFooter(color: Colors.red),
            onLoad: () async {
              if (hasmore) {
                var params = {
                  "id": songInfo.id,
                  "type": "0",
                  "sortType": '$sortTpye',
                  "pageNo": "${++currPage}"
                };
                if (sortTpye == 3) {
                  params["cursor"] = '${commentList.last['time']}';
                }
                print(params);
                _getCommentList(params).then((value) {
                  if (value != null) {
                    this.setState(() {
                      commentList.addAll(value["comments"]);
                      hasmore = value["hasMore"];
                    });
                    _controller.finishLoad(
                        noMore: commentList.length >= count, success: true);
                  } else {
                    this.setState(() {
                      hasmore = false;
                    });
                    _controller.finishLoad(noMore: true, success: true);
                  }
                });
              } else {
                _controller.finishLoad(noMore: true, success: true);
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    child: buildHead(),
                  ),
                  SizedBox(
                    height: 10,
                    child: Container(
                      color: Color.fromRGBO(247, 247, 247, 1),
                    ),
                  ),
                  StickyHeader(
                    header: Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 15, right: 15),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '评论区',
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  if (sortTpye != 1) {
                                    this.setState(() {
                                      firstrefresh = true;
                                      commentList = [];
                                      sortTpye = 1;
                                    });
                                    await _getFirstList({
                                      "id": songInfo.id,
                                      "type": "0",
                                      "sortType": '$sortTpye',
                                    });
                                  }
                                },
                                child: Text(
                                  '推荐',
                                  style: TextStyle(
                                    color: sortTpye == 1
                                        ? Colors.black87
                                        : Colors.black38,
                                    fontSize: 14,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(1, 1)),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.all(5),
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                              VerticalDivider(
                                width: 3,
                                endIndent: 15,
                                indent: 15,
                                color: Colors.black38,
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (sortTpye != 2) {
                                    this.setState(() {
                                      firstrefresh = true;
                                      commentList = [];
                                      sortTpye = 2;
                                    });
                                    await _getFirstList({
                                      "id": songInfo.id,
                                      "type": "0",
                                      "sortType": '$sortTpye',
                                    });
                                  }
                                },
                                child: Text(
                                  '最热',
                                  style: TextStyle(
                                    color: sortTpye == 2
                                        ? Colors.black87
                                        : Colors.black38,
                                    fontSize: 14,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(1, 1)),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.all(5),
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                              VerticalDivider(
                                width: 3,
                                endIndent: 15,
                                indent: 15,
                                color: Colors.black38,
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (sortTpye != 3) {
                                    this.setState(() {
                                      firstrefresh = true;
                                      commentList = [];
                                      sortTpye = 3;
                                    });
                                    await _getFirstList({
                                      "id": songInfo.id,
                                      "type": "0",
                                      "sortType": '$sortTpye',
                                    });
                                  }
                                },
                                child: Text(
                                  '时间',
                                  style: TextStyle(
                                    color: sortTpye == 3
                                        ? Colors.black87
                                        : Colors.black38,
                                    fontSize: 14,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(1, 1)),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.all(5),
                                  ),
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    content: firstrefresh
                        ? Container(
                            width: double.infinity,
                            height: 60,
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.lineScale,
                                      colors: const [Colors.red],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '加载中...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black38,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 25,
                            ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                height: 1.5,
                                color: Color(0xfff5f5f5),
                              );
                            },
                            itemBuilder: (context, index) {
                              return buildCommentWidget(commentList[index]);
                            },
                            itemCount: commentList.length,
                          ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
