import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_app/wight/playPaint.dart';

class PlayListStack extends StatefulWidget {
  double showopacity;
  String imageUrl;
  String appbarTitle;
  var playlistdetail;
  String collection;
  String chat;
  String share;
  int playCount;
  String avatorUrl;
  var backimage;
  PlayListStack({
    Key? key,
    required this.backimage,
    this.imageUrl = 'images/default/playlistdefault.png',
    this.appbarTitle = '歌单',
    this.playlistdetail,
    this.collection = '收藏',
    this.chat = '评论',
    this.share = '分享',
    this.playCount = 0,
    this.avatorUrl = '',
    this.showopacity = 0,
  }) : super(key: key);

  @override
  _PlayListStackState createState() => _PlayListStackState(
        imageUrl: this.imageUrl,
        appbarTitle: this.appbarTitle,
        playlistdetail: this.playlistdetail,
        chat: this.chat,
        collection: this.collection,
        playCount: this.playCount,
        share: this.share,
        avatorUrl: this.avatorUrl,
        backimage: this.backimage,
        showopacity: this.showopacity,
      );
}

class _PlayListStackState extends State<PlayListStack> {
  String imageUrl;
  String appbarTitle;
  var playlistdetail;
  String collection;
  String chat;
  String share;
  int playCount;
  String avatorUrl;
  var backimage;
  double showopacity;
  _PlayListStackState({
    this.imageUrl = 'images/default/playlistdefault.png',
    this.appbarTitle = '歌单',
    this.playlistdetail,
    this.collection = '收藏',
    this.chat = '评论',
    this.share = '分享',
    this.playCount = 0,
    this.avatorUrl = '',
    required this.backimage,
    this.showopacity = 0,
  });

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.setState(() {
      this.imageUrl = widget.imageUrl;
      this.appbarTitle = widget.appbarTitle;
      this.playlistdetail = widget.playlistdetail;
      this.collection = widget.collection;
      this.chat = widget.chat;
      this.share = widget.share;
      this.playCount = widget.playCount;
      this.avatorUrl = widget.avatorUrl;
      this.backimage = widget.backimage;
      this.showopacity = widget.showopacity;
    });
  }

  createBarInfo() {
    if (playlistdetail == null) {
      return Container(
        height: 120,
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            Text(
              '暂无数据',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 120,
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${playlistdetail["name"]}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child:
                        Image.network(playlistdetail["creator"]["avatarUrl"]),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '${playlistdetail["creator"]["nickname"]}',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            Text(
              '${playlistdetail["description"]}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  filterNum(String num) {
    var newnum = int.tryParse(num);
    if (newnum != null) {
      if (newnum > 10000) {
        return (newnum / 10000).toStringAsFixed(1) + '万';
      } else {
        return newnum.toString();
      }
    } else {
      return num;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: backimage, //背景图片
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            // make sure we apply clip it properly
            child: BackdropFilter(
              //背景滤镜
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), //背景模糊化
              child: Container(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            child: CustomPaint(
              painter: Sky(),
            ),
          ),
        ),
        Align(
          // width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: widget.showopacity,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: avatorUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(avatorUrl),
                              )
                            : Center(),
                      ),
                      Expanded(
                        child: createBarInfo(),
                        flex: 1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 300,
                    height: 40,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.library_add,
                            size: 18,
                          ),
                          label: Text(
                            filterNum(collection),
                          ),
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(0)),
                            foregroundColor:
                                MaterialStateProperty.resolveWith((state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Colors.black38;
                              } else {
                                return Colors.black87;
                              }
                            }),
                          ),
                        ),
                        VerticalDivider(),
                        TextButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.chat,
                            size: 18,
                          ),
                          label: Text(filterNum(chat)),
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(0)),
                            foregroundColor:
                                MaterialStateProperty.resolveWith((state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Colors.black38;
                              } else {
                                return Colors.black87;
                              }
                            }),
                          ),
                        ),
                        VerticalDivider(),
                        TextButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.share,
                            size: 18,
                          ),
                          label: Text(filterNum(share)),
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(0)),
                            foregroundColor:
                                MaterialStateProperty.resolveWith((state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Colors.black38;
                              } else {
                                return Colors.black87;
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
