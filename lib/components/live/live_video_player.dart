import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netease_app/components/live/live_url_fijk_player.dart';
import 'package:netease_app/components/live/live_url_player.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/wight/widget_future_builder.dart';

class LiveVideoPlayerPage extends StatefulWidget {
  String url; // 更名为房间号
  String title;
  String liveType; // 可能为空也可能有值
  String cover;
  LiveVideoPlayerPage(
      {Key? key,
      required this.url,
      this.title = '',
      required this.liveType,
      required this.cover})
      : super(key: key);

  @override
  _LiveVideoPlayerPageState createState() => _LiveVideoPlayerPageState(
      url: this.url,
      title: this.title,
      liveType: this.liveType,
      cover: this.cover);
}

class _LiveVideoPlayerPageState extends State<LiveVideoPlayerPage> {
  String url;
  String title;
  String liveType;
  String cover;
  var liverooinfo;
  _LiveVideoPlayerPageState(
      {required this.url,
      this.title = '',
      required this.liveType,
      required this.cover});

  @override
  void initState() {
    super.initState();
    liverooinfo = _getroomurl();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getroomurl() async {
    Map<String, dynamic> params = {"roomid": url};
    var data = await getLiveRoom(params);
    if (data != null) {
      return data;
    } else {
      return null;
    }
  }

  _getmisiLive(context, params) async {
    var data;
    if (liveType.isNotEmpty) {
      data = await getdouyuAllList(params, id: liveType);
    } else {
      data = await getdouyuAllList(params);
    }

    if (data["error"] == 0) {
      return data["data"];
    } else {
      return [];
    }
  }

  createsimimvList() {
    return CustomFutureBuilder(
      futureFunc: _getmisiLive,
      params: {"limit": "20", "offset": "0"},
      loadingWidget: Container(),
      builder: (context, value) {
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
        Navigator.of(context).pushNamed('/liveroom', arguments: {
          "url": item["room_id"],
          "title": item["room_name"],
          "liveType": liveType,
          "cover": item["room_src"],
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Container(
              width: 160,
              height: 90,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: item["room_src"],
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
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
                    item['room_name'],
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
                        item['nickname'],
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
                              text: item['game_name'],
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
                              text: '热度${item['online']}',
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
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery.removePadding(
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
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: AppBar(
                  title: Text(
                    '高度',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: liverooinfo,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            'error',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }

                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return LiveFijkPlayerWidget(
                        url: snapshot.data["Rendata"]["link"],
                        title: title,
                      );
                      return LiveUrlVideoPlayerWidget(
                        url: snapshot.data["Rendata"]["link"],
                        title: title,
                      );
                    case ConnectionState.waiting:
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              'loading',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    case ConnectionState.none:
                    default:
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              'error',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                  }
                },
              ),
              Container(
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: cover,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'images/default/playlistdefault.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        errorWidget: (context, url, error) => ClipRRect(
                          borderRadius: BorderRadius.circular(50),
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
                    Text(title)
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 10),
                  children: [
                    createsimimvList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
