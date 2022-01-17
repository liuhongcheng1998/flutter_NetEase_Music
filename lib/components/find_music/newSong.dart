// 新歌
// 他可能会有三个模块 新歌  新碟  数字专辑

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NewSongPage extends StatefulWidget {
  List newSongList;
  NewSongPage({Key? key, required this.newSongList}) : super(key: key);

  @override
  _NewSongPageState createState() =>
      _NewSongPageState(newSongList: this.newSongList);
}

class _NewSongPageState extends State<NewSongPage> {
  List newSongList;
  List showList = [];
  String activeType = "NEW_SONG_HOMEPAGE";
  _NewSongPageState({required this.newSongList});

  @override
  void initState() {
    super.initState();
    getshowlist();
  }

  getCheckButton() {
    // 获取button类型
    List<Widget> buttonlist = <Widget>[];
    if (newSongList
        .any((element) => element["creativeType"] == "NEW_SONG_HOMEPAGE")) {
      // 是否有新歌
      buttonlist.add(TextButton(
        onPressed: () {
          if (activeType != "NEW_SONG_HOMEPAGE") {
            setState(() {
              this.activeType = "NEW_SONG_HOMEPAGE";
            });
            getshowlist();
          }
        },
        child: Text(
          '新歌',
          style: TextStyle(
            color: activeType == "NEW_SONG_HOMEPAGE"
                ? Colors.black87
                : Colors.black38,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(1, 1)),
          padding: MaterialStateProperty.all(
            EdgeInsets.all(5),
          ),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ));
      buttonlist.add(VerticalDivider(
        width: 3,
        endIndent: 5,
        indent: 10,
        color: Colors.black,
      ));
    }
    if (newSongList
        .any((element) => element["creativeType"] == "NEW_ALBUM_HOMEPAGE")) {
      // 是否有新歌
      buttonlist.add(TextButton(
        onPressed: () {
          if (activeType != "NEW_ALBUM_HOMEPAGE") {
            setState(() {
              this.activeType = "NEW_ALBUM_HOMEPAGE";
            });
            getshowlist();
          }
        },
        child: Text(
          '新碟',
          style: TextStyle(
            color: activeType == "NEW_ALBUM_HOMEPAGE"
                ? Colors.black87
                : Colors.black38,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(1, 1)),
          padding: MaterialStateProperty.all(
            EdgeInsets.all(5),
          ),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ));
      buttonlist.add(VerticalDivider(
        width: 3,
        endIndent: 5,
        indent: 10,
        color: Colors.black,
      ));
    }
    if (newSongList.any(
        (element) => element["creativeType"] == "DIGITAL_ALBUM_HOMEPAGE")) {
      // 是否有新歌
      buttonlist.add(TextButton(
        onPressed: () {
          if (activeType != "DIGITAL_ALBUM_HOMEPAGE") {
            setState(() {
              this.activeType = "DIGITAL_ALBUM_HOMEPAGE";
            });
            getshowlist();
          }
        },
        child: Text(
          '数字专辑',
          style: TextStyle(
            color: activeType == "DIGITAL_ALBUM_HOMEPAGE"
                ? Colors.black87
                : Colors.black38,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(1, 1)),
          padding: MaterialStateProperty.all(
            EdgeInsets.all(5),
          ),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ));
    }
    return buttonlist;
  }

  filterartists(List artists) {
    String artistList = '';
    artists.forEach((element) {
      artistList += element["name"] + '/';
    });
    return artistList.substring(0, artistList.length - 1);
  }

  filtersubTitle(item) {
    if (item["titleType"] == "songRcmdTag") {
      // 说明这是一个标签
      return Container(
        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
        child: Text(
          item["title"],
          style: TextStyle(
            color: Color.fromRGBO(189, 127, 104, 1),
            fontSize: 10,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(
          item["title"],
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.6),
            fontSize: 12,
          ),
        ),
      );
    }
  }

  getshowlist() {
    List checkList = newSongList
        .where((element) => element["creativeType"] == activeType)
        .toList();
    setState(() {
      showList = checkList;
    });
  }

  createColumList(item) {
    List<Widget> songItemList = <Widget>[];
    item["resources"].forEach((element) {
      songItemList.add(SizedBox(
        height: 10,
      ));
      songItemList.add(createItem(element));
    });
    return songItemList;
  }

  createItem(item) {
    return Container(
      width: double.infinity,
      height: 60,
      child: Row(
        children: [
          // 图片
          Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                item["uiElement"]["image"]["imageUrl"] + '?param=60y60',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 上下文字
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item["uiElement"]["mainTitle"]["title"],
                      ),
                      // 跟上艺术家
                      TextSpan(
                          text:
                              ' -  ${filterartists(item["resourceExtInfo"]["artists"])}',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.38),
                            fontSize: 10,
                          ))
                    ],
                  ),
                ),
                filtersubTitle(item["uiElement"]["subTitle"] ??
                    {"titleType": '', "title": ""}),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 34,
                child: Row(
                  children: getCheckButton(),
                ),
              ),
              Container(
                height: 28,
                child: OutlinedButton(
                  onPressed: () => {},
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    )),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shape: MaterialStateProperty.all(
                      StadiumBorder(
                        side: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    '播放',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            height: 210,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.95,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Column(
                    children: createColumList(showList[index]),
                  ),
                );
              },
              itemCount: showList.length,
            ),
          )
        ],
      ),
    );
  }
}
