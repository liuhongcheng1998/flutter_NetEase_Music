// 每日推荐单曲

import 'package:animate_do/animate_do.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/preferences/user_preferences.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:netease_app/style/textstyle.dart';
import 'package:netease_app/wight/recommendAppbar.dart';

class RecommendSingle extends StatefulWidget {
  RecommendSingle({Key? key}) : super(key: key);

  @override
  _RecommendSingleState createState() => _RecommendSingleState();
}

class _RecommendSingleState extends State<RecommendSingle> {
  var recommendinfo;
  int songcount = 0;
  List getsongslist = [];
  @override
  void initState() {
    super.initState();
    recommendinfo = _getrecommendsongs();
  }

  Future _getrecommendsongs() async {
    var data = await getRecommendSingle();
    if (data["code"] == 200) {
      this.setState(() {
        songcount = data["data"]["dailySongs"].length;
        getsongslist = data["data"]["dailySongs"];
      });
      return data["data"];
    } else {
      return null;
    }
  }

  screenishavesong(PageManager model, List list, int songid, songindex) {
    // songmodel.allSongs.forEach((element) {

    // });
    int index = list.indexWhere((element) => element.id == songid.toString());
    print(index);
    if (index > 0) {
      model.playInex(index);
    } else {
      playallsong(
        index: songindex,
      );
    }
  }

  createArtistString(List list) {
    List artistString = [];
    list.forEach((element) {
      artistString.add(element["name"]);
    });
    return artistString.join('/');
  }

  playallsong({int index = 0}) async {
    final model = getIt<PageManager>();
    List<Song> playsongslist = <Song>[];
    getsongslist.forEach((element) {
      playsongslist.add(Song(
        element["id"],
        Duration(milliseconds: element["dt"]),
        name: element["name"],
        picUrl: element["al"]["picUrl"],
        artists: createArtistString(element["ar"]),
      ));
    });
    await model.changesonglistplay(playsongslist, index: index);
    model.changeIsPersonFm(false);
    model.play();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {});
    });
  }

  createSongItems(item, int index, List recommendReasons) {
    final model = getIt<PageManager>();
    List otherList = [];
    recommendReasons.forEach((element) {
      if (element["songId"] == item["id"]) {
        otherList.add(element["reason"]);
      }
    });

    return ValueListenableBuilder<MediaItem>(
      valueListenable: model.currentSongTitleNotifier,
      builder: (context, value, child) {
        bool ispaly = false;
        if (item["id"].toString() == value.id) {
          ispaly = true;
        }

        return ValueListenableBuilder<List>(
          valueListenable: model.playlistNotifier,
          builder: (context, allpalylist, child) {
            return Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListTile(
                onTap: () {
                  screenishavesong(
                      model, allpalylist, item["id"].toInt(), index);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                leading: Container(
                  width: 80,
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            '${item['al']['picUrl']}?param=50y50',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Center(
                        child: ispaly
                            ? Container(
                                height: 10,
                                width: 10,
                                margin: EdgeInsets.only(right: 10),
                                child: LoadingIndicator(
                                  indicatorType: Indicator.lineScale,
                                  colors: const [Colors.red],
                                ),
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                ),
                title: Transform(
                  transform: Matrix4.translationValues(-16, 0, 0),
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          item["name"],
                          style: TextStyle(
                            fontSize: 15,
                            color: ispaly ? Colors.red : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      otherList.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(left: 10),
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              color: Colors.red[50],
                              child: Text(
                                otherList.join(','),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                subtitle: Transform(
                  transform: Matrix4.translationValues(-16, 0, 0),
                  child: createartists(item["ar"], item),
                ),
                trailing: createrightaction(item),
              ),
            );
          },
        );
      },
    );
  }

  createismvicon(int mvid) {
    if (mvid != 0) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).pushNamed('/videoplaylist', arguments: {
            "id": mvid,
            "type": 0,
          });
        },
        child: Icon(Icons.smart_display),
      );
    } else {
      return SizedBox();
    }
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
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  createitemsubtitle(item) {
    return <InlineSpan>[
      TextSpan(
        text: ' - ',
        style: songsubtitle,
      ),
      TextSpan(
        text: "${item["al"]["name"]}",
        style: songsubtitle,
      )
    ];
  }

  createartists(List list, item) {
    List<InlineSpan> textChild = <InlineSpan>[];
    list.forEach((element) {
      textChild.add(TextSpan(text: "${element["name"]}", style: songsubtitle));
      textChild.add(TextSpan(text: "/", style: songsubtitle));
    });
    textChild.removeLast();
    textChild.addAll(createitemsubtitle(item));
    List<Widget> istag = [];
    if (item["fee"] == 1) {
      istag.add(Container(
        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        margin: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.red,
        ),
        child: Text(
          'vip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ));
    }
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
    istag.add(Expanded(
      child: Text.rich(
        TextSpan(
          children: textChild,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      flex: 1,
    ));
    return Row(
      children: istag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Color.fromRGBO(178, 178, 178, 1),
                centerTitle: true, // 不用过多解释
                pinned: true, // 设置为true时，当SliverAppBar内容滑出屏幕时，将始终渲染一个固定在顶部的收起状态
                elevation: 0, // 阴影
                // snap: true,
                // floating: true,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                stretch: true,
                iconTheme: IconThemeData(color: Colors.white),
                expandedHeight: 310.0,
                title: Text(
                  '每日推荐',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                bottom: new PreferredSize(
                  preferredSize: const Size.fromHeight(40.0),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            playallsong();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle,
                                color: Colors.red,
                                size: 34,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '播放全部',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: SizedBox(
                                        width: 10,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '($songcount)',
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                flexibleSpace: RecommendFlexibleSpaceBar(
                  background: Container(),
                ),
              ),
              FutureBuilder(
                future: recommendinfo,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  child: Icon(Icons.error),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '加载失败...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black38,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }, childCount: 1),
                    );
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.done:
                      List dailySongs = snapshot.data["dailySongs"];
                      List recommendReasons = snapshot.data["recommendReasons"];
                      if (dailySongs.isNotEmpty) {
                        return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            if (index + 1 == dailySongs.length + 1) {
                              return SizedBox(
                                height: 60,
                              );
                            } else {
                              return createSongItems(
                                  dailySongs[index], index, recommendReasons);
                            }
                          }, childCount: dailySongs.length + 1),
                        );
                      } else {
                        return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return Container();
                          }, childCount: 1),
                        );
                      }

                    case ConnectionState.waiting:
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.lineScale,
                                      colors: const [Colors.red],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '正在加载...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black38,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }, childCount: 1),
                      );
                    case ConnectionState.none:
                    default:
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child: Icon(Icons.error),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '加载失败...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black38,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }, childCount: 1),
                      );
                  }
                },
              ),
            ],
          ),
          FadeInUp(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ButtonPlayWight(),
            ),
          ),
        ],
      ),
    );
  }
}
