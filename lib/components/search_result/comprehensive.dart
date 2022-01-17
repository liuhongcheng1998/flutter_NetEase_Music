// 综合搜索
import 'package:audio_service/audio_service.dart';
import 'package:common_utils/common_utils.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/style/textstyle.dart';

// ignore: must_be_immutable
class ComprehensiveWidget extends StatefulWidget {
  String searchvalue;
  ComprehensiveWidget({Key? key, this.searchvalue = ''}) : super(key: key);

  @override
  _ComprehensiveWidgetState createState() =>
      _ComprehensiveWidgetState(searchvalue: this.searchvalue);
}

class _ComprehensiveWidgetState extends State<ComprehensiveWidget>
    with AutomaticKeepAliveClientMixin {
  String searchvalue;
  _ComprehensiveWidgetState({this.searchvalue = ''});
  var searchResult;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (searchvalue.isNotEmpty) {
      searchResult = _getSearchResult();
    }
  }

  _getSearchResult() async {
    var params = {
      "keywords": searchvalue,
      "type": "1018",
    };
    var data = await searchValueResult(params);
    if (data["code"] == 200) {
      return data["result"];
    } else {
      return null;
    }
  }

  // ==============你可能感兴趣=================
  // ====tips 可能感兴趣就是在专辑、歌单、艺人抽出第一位显示

  _createInterested(item) {
    return <Widget>[
      Row(
        children: [
          Text(
            '可能感兴趣',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Column(
        children: [
          // 歌手
          GestureDetector(
            child: Container(
              height: 60,
              margin: EdgeInsets.only(bottom: 10),
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
                              '${item["artist"]["artists"][0]["picUrl"]}?param=100y100',
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
                                  text:
                                      '歌手: ${item["artist"]["artists"][0]["name"]} ${item["artist"]["artists"][0]["alias"].length > 0 ? '(${item["artist"]["artists"][0]["alias"][0]})' : ''}',
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
                ],
              ),
            ),
          ),
          // 专辑
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            child: Container(
              height: 60,
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${item["album"]["albums"][0]["picUrl"]}?param=100y100',
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
                          Text(
                            '专辑: ${item["album"]["albums"][0]["name"]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: item["album"]["albums"][0]["artist"]
                                    ["name"],
                                style: songsubtitle,
                              ),
                              WidgetSpan(
                                child: SizedBox(
                                  width: 10,
                                ),
                              ),
                              TextSpan(
                                text: DateUtil.formatDateMs(
                                    item["album"]["albums"][0]["publishTime"],
                                    format: "yyyy-MM-dd"),
                                style: songsubtitle,
                              ),
                            ]),
                          ),
                          item["album"]["albums"][0]["onSale"]
                              ? Text(
                                  '数字专辑出售中',
                                  style: songsubtitle,
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
          // 歌单
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/playlist',
                  arguments: item["playList"]["playLists"][0]["id"]);
            },
            child: Container(
              height: 60,
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${item["playList"]["playLists"][0]["coverImgUrl"]}?param=100y100',
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
                            text:
                                '歌单: ${item["playList"]["playLists"][0]["name"]}',
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
                          Row(
                            children: [
                              Text(
                                '${item["playList"]["playLists"][0]["trackCount"]}首音乐 ',
                                style: songsubtitle,
                              ),
                              Container(
                                width: 50,
                                child: Text(
                                  "by ${item["playList"]["playLists"][0]["creator"]["nickname"]} ,  ",
                                  style: songsubtitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Text(
                                "播放${computePlayCount(item["playList"]["playLists"][0]["playCount"])}次",
                                style: songsubtitle,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                        ],
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    ];
  }

  computePlayCount(int playcout) {
    if (playcout > 10000) {
      print((playcout / 10000).toStringAsFixed(1) + '万');
      return (playcout / 10000).toStringAsFixed(1) + '万';
    } else {
      print(playcout.toString());
      return playcout.toString();
    }
  }

  // ===================用户=================

  _createUserList(List userlist) {
    List<Widget> userItems = userlist.map((item) {
      return GestureDetector(
        child: Container(
          height: 60,
          margin: EdgeInsets.only(bottom: 10),
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
                          '${item["avatarUrl"]}?param=100y100',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SubstringHighlight(
                              text: item["nickname"],
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
                            SizedBox(
                              width: 5,
                            ),
                            item["gender"] == 1
                                ? Icon(
                                    Icons.male,
                                    color: Color.fromRGBO(114, 164, 201, 1),
                                    size: 14,
                                  )
                                : Icon(
                                    Icons.female,
                                    color: Colors.pink,
                                    size: 14,
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
                    color: item["followed"] ? Colors.black38 : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item["followed"] ? Icons.check : Icons.add,
                      size: 12,
                      color: item["followed"] ? Colors.black38 : Colors.red,
                    ),
                    Text(
                      '${item["followed"] ? '已关注' : '关注'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: item["followed"] ? Colors.black38 : Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }).toList();
    return Column(
      children: userItems,
    );
  }

  _createSearchUser(user) {
    return <Widget>[
      Row(
        children: [
          Text(
            '用户',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      _createUserList(user["users"]),
      Divider(
        height: 1,
      ),
      user["more"]
          ? GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubstringHighlight(
                      text: user["moreText"],
                      term: searchvalue,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyleHighlight: TextStyle(
                        // highlight style
                        color: Color.fromRGBO(66, 125, 172, 1),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    ];
  }

  // ====================相关搜索================
  _createRelevantList(List simList) {
    List<Widget> simItems = simList.map((item) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
        margin: EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color.fromRGBO(248, 248, 248, 1),
        ),
        child: Text(
          item["keyword"],
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      );
    }).toList();
    return Wrap(
      children: simItems,
    );
  }

  _createRelevant(simQuery) {
    return <Widget>[
      Row(
        children: [
          Text(
            '相关搜索',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      _createRelevantList(simQuery["sim_querys"]),
    ];
  }

  // ==================专辑=====================

  _createAlbumItem(List albumlist) {
    List<Widget> albumItems = albumlist.map((item) {
      return Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: item["artist"]["name"],
                          style: songsubtitle,
                        ),
                        WidgetSpan(
                          child: SizedBox(
                            width: 10,
                          ),
                        ),
                        TextSpan(
                          text: DateUtil.formatDateMs(item["publishTime"],
                              format: "yyyy-MM-dd"),
                          style: songsubtitle,
                        ),
                      ]),
                    ),
                    item["onSale"]
                        ? Text(
                            '数字专辑出售中',
                            style: songsubtitle,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      );
    }).toList();

    return Column(
      children: albumItems,
    );
  }

  _createalbumCard(album) {
    return <Widget>[
      Row(
        children: [
          Text(
            '专辑',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      _createAlbumItem(album["albums"]),
      Divider(
        height: 1,
      ),
      album["more"]
          ? GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubstringHighlight(
                      text: album["moreText"],
                      term: searchvalue,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyleHighlight: TextStyle(
                        // highlight style
                        color: Color.fromRGBO(66, 125, 172, 1),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    ];
  }

// ==================艺人模块=====================

  _createartistItems(List artistList) {
    List<Widget> artistItem = artistList.map((item) {
      return Container(
        height: 60,
        margin: EdgeInsets.only(bottom: 10),
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
                  color: item["followed"] ? Colors.black38 : Colors.red,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item["followed"] ? Icons.check : Icons.add,
                    size: 12,
                    color: item["followed"] ? Colors.black38 : Colors.red,
                  ),
                  Text(
                    '${item["followed"] ? '已关注' : '关注'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: item["followed"] ? Colors.black38 : Colors.red,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }).toList();

    return Column(
      children: artistItem,
    );
  }

  _createartistCard(artist) {
    return <Widget>[
      Row(
        children: [
          Text(
            '艺人',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      _createartistItems(artist["artists"]),
      Divider(
        height: 1,
      ),
      artist["more"]
          ? GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubstringHighlight(
                      text: artist["moreText"],
                      term: searchvalue,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyleHighlight: TextStyle(
                        // highlight style
                        color: Color.fromRGBO(66, 125, 172, 1),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    ];
  }

// =====================歌单======================
  _createlistItems(List playlists) {
    List<Widget> playitem = playlists.map((item) {
      List<Widget> istag = <Widget>[];
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
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/playlist', arguments: item["id"]);
        },
        child: Container(
          height: 60,
          margin: EdgeInsets.only(bottom: 10),
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
                      Text(
                        item["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
    }).toList();
    return Column(
      children: playitem,
    );
  }

  _creartSongsList(playlist) {
    // 歌单
    return <Widget>[
      Row(
        children: [
          Text(
            '歌单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      _createlistItems(playlist["playLists"]),
      Divider(
        height: 1,
      ),
      playlist["more"]
          ? GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubstringHighlight(
                      text: playlist["moreText"],
                      term: searchvalue,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyleHighlight: TextStyle(
                        // highlight style
                        color: Color.fromRGBO(66, 125, 172, 1),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    ];
  }

// =======================单曲===================
  _creartSongs(songs) {
    // 单曲
    return <Widget>[
      Row(
        children: [
          Text(
            '单曲',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 8,
      ),
      Divider(
        height: 1,
      ),
      _createSongsItem(songs["songs"]),
      Divider(
        height: 1,
      ),
      songs["more"]
          ? GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SubstringHighlight(
                      text: songs["moreText"],
                      term: searchvalue,
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textStyleHighlight: TextStyle(
                        // highlight style
                        color: Color.fromRGBO(66, 125, 172, 1),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    ];
  }

  Widget _createSongsItem(List songlist) {
    final model = getIt<PageManager>();
    List<Widget> songwidget = songlist.map((item) {
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
              await model.add(Song(
                item["id"],
                Duration(microseconds: item["dt"]),
                artists: createArtistString(item["ar"]),
                picUrl: item["al"]["picUrl"],
                name: item["name"],
              ));
              await model.play();
            },
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ispaly
                      ? Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 5),
                          child: LoadingIndicator(
                            indicatorType: Indicator.lineScaleParty,
                            colors: const [Colors.red],
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: Color.fromRGBO(66, 125, 172, 1),
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
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ListTile.divideTiles(
        tiles: songwidget,
        context: context,
        color: Colors.black38,
      ).toList(),
    );
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
    if (item["officialTags"].isNotEmpty) {
      item["officialTags"].forEach((item) {
        istag.add(
          Container(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
            margin: EdgeInsets.only(right: 5),
            color: Color.fromRGBO(255, 249, 228, 1),
            child: Text(
              item,
              style: TextStyle(
                color: Color.fromRGBO(221, 137, 103, 1),
                fontSize: 12,
              ),
            ),
          ),
        );
      });
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
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 10, right: 10),
      child: FutureBuilder(
        future: searchResult,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container(
              height: 100,
              margin: EdgeInsets.only(top: 30),
              child: Center(
                child: Text('搜索失败!'),
              ),
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  // 可能感兴趣
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _createInterested(snapshot.data),
                      ),
                    ),
                  ),
                  // 单曲
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _creartSongs(snapshot.data["song"]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // 歌单
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _creartSongsList(snapshot.data["playList"]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // 艺人
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _createartistCard(snapshot.data["artist"]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // 专辑
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: _createalbumCard(snapshot.data["album"]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // 相关搜索
                  snapshot.data["sim_query"] != null
                      ? Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  _createRelevant(snapshot.data["sim_query"]),
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  // 用户
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _createSearchUser(snapshot.data["user"]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                ],
              );
            case ConnectionState.waiting:
              return Container(
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
              );
            case ConnectionState.none:
            default:
              return Container(
                margin: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text('搜索失败!'),
                ),
              );
          }
        },
      ),
    );
  }
}
