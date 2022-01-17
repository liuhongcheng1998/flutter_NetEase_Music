// 歌单详情页

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:netease_app/style/textstyle.dart';
import 'package:netease_app/wight/playlistAppBar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:animate_do/animate_do.dart';

class PlayListPage extends StatefulWidget {
  final int playlistId;
  PlayListPage({Key? key, required this.playlistId}) : super(key: key);

  @override
  _PlayListPageState createState() =>
      _PlayListPageState(playlistId: this.playlistId);
}

class _PlayListPageState extends State<PlayListPage> {
  final int playlistId;
  _PlayListPageState({required this.playlistId});

  var playlistdet;
  var songsList;

  List getsongslist = [];

  @override
  void initState() {
    super.initState();
    playlistdet = _getplaylistdet();
    songsList = playlistdet.then((res) {
      return getsongList(res["trackIds"]);
    });
  }

  Future _getplaylistdet() async {
    var params = {
      "id": playlistId.toString(),
    };
    var data = await getPlaylistDetail(params);
    print('数据============$data');
    if (data["code"] == 200) {
      return data["playlist"];
    } else {
      return null;
    }
  }

  Future _getplaylistsongs(List list) async {
    var params = {
      "ids": list.join(','),
    };
    var data = await getPlaylistSongs(params);

    if (data["code"] == 200) {
      return data["songs"];
    } else {
      return [];
    }
  }

  getsongList(List songidlist) {
    List idlist = [];
    songidlist.forEach((element) {
      idlist.add(element["id"]);
    });

    return _getplaylistsongs(idlist);
  }

  screenishavesong(PageManager model, List list, int songid, songindex) {
    // songmodel.allSongs.forEach((element) {

    // });
    int index = list.indexWhere((element) => element.id == songid.toString());
    print(index);
    if (index > 0) {
      model.playInex(index);
    } else {
      playallsong(index: songindex);
    }
  }

  createSongItems(item, int index) {
    final model = getIt<PageManager>();

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
                  width: 50,
                  height: 55,
                  child: Center(
                    child: ispaly
                        ? Container(
                            height: 20,
                            width: 20,
                            child: LoadingIndicator(
                              indicatorType: Indicator.lineScale,
                              colors: const [Colors.red],
                            ),
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                title: Transform(
                  transform: Matrix4.translationValues(-16, 0, 0),
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

  playallsong({int index = 0}) async {
    print('触发播放全部$getsongslist');
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

  createArtistString(List list) {
    List artistString = [];
    list.forEach((element) {
      artistString.add(element["name"]);
    });
    return artistString.join('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        CustomScrollView(
          slivers: [
            FutureBuilder(
              future: playlistdet,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return PlaylistAppBar();
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.data != null) {
                      return PlaylistAppBar(
                        imageUrl: snapshot.data["backgroundCoverUrl"] != null
                            ? snapshot.data["backgroundCoverUrl"]
                            : snapshot.data["coverImgUrl"],
                        appbarTitle: snapshot.data["name"],
                        avatorUrl: snapshot.data["coverImgUrl"],
                        playCount: snapshot.data["trackCount"],
                        chat: snapshot.data["commentCount"].toString(),
                        share: snapshot.data["shareCount"].toString(),
                        collection: snapshot.data["subscribedCount"].toString(),
                        playlistdetail: snapshot.data,
                        playall: playallsong,
                      );
                    } else {
                      return PlaylistAppBar();
                    }
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  default:
                    return PlaylistAppBar();
                }
              },
            ),
            FutureBuilder(
              future: songsList,
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
                    List songList = snapshot.data;
                    getsongslist = songList;

                    if (songList.isNotEmpty) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index + 1 == songList.length + 1) {
                            return SizedBox(
                              height: 60,
                            );
                          } else {
                            return createSongItems(songList[index], index);
                          }
                        }, childCount: songList.length + 1),
                      );
                    } else {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
    ));
  }
}
