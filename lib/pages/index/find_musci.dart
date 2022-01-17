// 发现页

import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/components/find_music/musicCalendar.dart';
import 'package:netease_app/components/find_music/newSong.dart';
import 'package:netease_app/components/find_music/personality.dart';
import 'package:netease_app/components/find_music/recommend.dart';
import 'package:netease_app/components/find_music/selectedVideo.dart';
import 'package:netease_app/components/find_music/slidelist.dart';
import 'package:netease_app/components/pagination.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/notifiers/play_button_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:provider/provider.dart';

class FindMusicPage extends StatefulWidget {
  FindMusicPage({Key? key}) : super(key: key);

  @override
  _FindMusicPageState createState() => _FindMusicPageState();
}

class _FindMusicPageState extends State<FindMusicPage>
    with SingleTickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  var search_tips;
  List findMusicList = []; // 发现页全部数据
  var cursor;
  late EasyRefreshController _controller;
  late AnimationController controller;
  var timer;

  /// 这里要区分是否是登录状态
  /// 如果是登录状态 则会分页 (恶心)
  /// 如果是未登录状态 则一次性返回
  /// 接口会多一个refresh 刷新时传入true这回获得新的数据
  /// 还有一个cursor 这个用于登录状态

  @override
  void initState() {
    super.initState();
    search_tips = _getsearchlist();
    _controller = EasyRefreshController();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), //动画持续的时长
        vsync: this //作用的statefulWidget实例
        );
  }

  @override
  void dispose() {
    timer.cancel();
    timer = null;
    super.dispose();
  }

  Future _getsearchlist() async {
    var data = await getHotSearchList();
    if (data["code"] == 200) {
      return data["result"]["hots"];
    } else {
      return [];
    }
  }

  Future _findMusicAllList(params) async {
    var data = await getFindMusicAll(params);
    print(data);
    if (data["code"] == 200) {
      return data["data"];
    } else {
      return null;
    }
  }

  String _createStringList(item) {
    return item["first"].toString();
  }

  Future getPersonFMlist() async {
    final model = getIt<PageManager>();
    Map<String, dynamic> params = {
      "timestamp": '${DateTime.now().microsecondsSinceEpoch}',
    };
    if (model.isPersonFm.value) {
      // 如果当前本来就是私人FM
      if (model.playButtonNotifier.value == ButtonState.playing) {
        // 如果现在正在播放 跳转到歌曲页
        return Navigator.of(context).pushNamed('/playsongs');
      } else {
        // 如果现在没有播放 打开播放并且跳转到歌曲页
        model.resumePlay();
        return Navigator.of(context).pushNamed('/playsongs');
      }
    } else {
      // 如果当前不是私人FM
      getPersonaFm(params).then((value) {
        if (value["code"] == 200) {
          List<Song> playsongslist = <Song>[];
          value["data"].forEach((element) {
            playsongslist.add(Song(
              element["id"],
              Duration(milliseconds: element["duration"]),
              name: element["name"],
              picUrl: element["album"]["picUrl"],
              artists: createArtistString(element["artists"]),
            ));
          });

          model.changesonglistplay(playsongslist, index: 0);
          model.changeIsPersonFm(true);
          model.play();
          timer = Timer(Duration(seconds: 1), () {
            if (model.playButtonNotifier.value == ButtonState.playing) {
              timer.cancel();
              timer = null;
              Navigator.of(context).pushNamed('/playsongs');
            }
          });
        }
      });
    }
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
        backgroundColor: Color.fromRGBO(248, 248, 248, 1),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          centerTitle: true,
          leading: Icon(
            Icons.format_align_left,
            color: Colors.black,
          ),
          actions: [
            Icon(
              Icons.mic,
              color: Colors.black,
            ),
            SizedBox(
              width: 10,
            )
          ],
          title: Container(
            alignment: Alignment.center,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              color: Colors.white,
            ),
            child: FutureBuilder(
              future: search_tips,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '搜索',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return Swiper(
                      loop: true,
                      autoplay: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      autoplayDelay: 10000,
                      onTap: (int index) {
                        // 获取到下标
                        String activeName = snapshot.data[index]["first"];
                        List list =
                            snapshot.data.map(_createStringList).toList();

                        // 跳转页面到搜索页
                        Navigator.of(context).pushNamed('/search', arguments: {
                          "searchTips": list,
                          "searchTip": activeName,
                        });
                      },
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              snapshot.data[index]["first"],
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                  default:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '搜索',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              EasyRefresh(
                firstRefresh: true,
                firstRefreshWidget: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Container(
                      height: 20,
                      width: 20,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballGridPulse,
                        colors: const [Colors.red],
                      ),
                    ),
                  ),
                ),
                enableControlFinishRefresh: false,
                enableControlFinishLoad: true,
                controller: _controller,
                header: MaterialHeader(
                  backgroundColor: Colors.black,
                  valueColor: ColorTween(begin: Colors.white, end: Colors.white)
                      .animate(controller),
                ),
                onRefresh: () async {
                  setState(() {
                    findMusicList = [];
                  });
                  Map<String, dynamic> params = {
                    "refresh": true,
                  };
                  _findMusicAllList(params).then((value) {
                    if (value != null) {
                      setState(() {
                        findMusicList.addAll(value["blocks"]);
                        findMusicList.insert(1, {"blockCode": "ADD_MENU_LIST"});
                      });
                      if (value["hasMore"]) {
                        _controller.finishLoad(noMore: false);
                        setState(() {
                          cursor = value["cursor"];
                        });
                      } else {
                        _controller.finishLoad(noMore: true);
                      }
                      _controller.finishRefresh(success: true);
                    } else {
                      _controller.finishRefresh(success: true);
                    }
                  });
                  _controller.resetLoadState();
                },
                onLoad: () async {
                  Map<String, dynamic> params = {};
                  if (cursor != null) {
                    params["cursor"] = cursor;
                  }
                  _findMusicAllList(params).then((res) {
                    if (res != null) {
                      setState(() {
                        findMusicList.addAll(res["blocks"]);
                      });
                      if (res["hasMore"]) {
                        _controller.finishLoad(noMore: false, success: true);
                        setState(() {
                          cursor = res["cursor"];
                        });
                      } else {
                        _controller.finishLoad(noMore: true, success: true);
                      }
                    } else {
                      _controller.finishLoad(noMore: true, success: true);
                    }
                  }).catchError((e) {
                    _controller.finishLoad(noMore: true, success: true);
                  });
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    /// 其他还有几个模块没有上 HOMEPAGE_PODCAST24 广播电台
                    /// HOMEPAGE_BLOCK_FUN_CLUB 云村ktv
                    /// HOMEPAGE_BLOCK_TOPLIST 排行榜
                    /// HOMEPAGE_BLOCK_LISTEN_LIVE look直播
                    /// HOMEPAGE_VOICELIST_RCMD 热门博客 有声书
                    var element = findMusicList[index];
                    switch (element["blockCode"]) {
                      case "HOMEPAGE_BANNER":
                        // 轮播图
                        List bannerList = element["extInfo"]["banners"];
                        return Container(
                          height: 150,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          child: Swiper(
                            loop: true,
                            autoplay: true,
                            itemBuilder: (context, int index) {
                              return Container(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    bannerList[index]["pic"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            itemCount: bannerList.length,
                            pagination: MySwiperPagination(
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            ),
                          ),
                        );

                      case "HOMEPAGE_BLOCK_PLAYLIST_RCMD":
                        // 推荐歌单
                        List playlist = element["creatives"];
                        return RecommendListPage(
                          recommendList: playlist,
                        );
                      case "HOMEPAGE_BLOCK_STYLE_RCMD":
                        // 个性推荐
                        var personality = element;
                        return PersonalityPage(
                          personalityInfo: personality,
                        );
                      case "HOMEPAGE_BLOCK_NEW_ALBUM_NEW_SONG":
                        List newsonglist = element["creatives"];
                        // 新歌
                        return NewSongPage(
                          newSongList: newsonglist,
                        );

                      case "HOMEPAGE_MUSIC_CALENDAR":
                        List calendarlist = element["creatives"];

                        return MusicCalenderPage(
                          calenderList: calendarlist,
                        );
                      case "HOMEPAGE_MUSIC_MLOG":
                        List videoList = element["extInfo"];
                        return SelectedVideoPage(
                          videoList: videoList,
                        );
                      case "HOMEPAGE_BLOCK_MGC_PLAYLIST":
                        List slideplaylist = element["creatives"];
                        String slideTitle =
                            element["uiElement"]["subTitle"]["title"];
                        return SlideListPage(
                          recommendList: slideplaylist,
                          title: slideTitle,
                        );
                      case "HOMEPAGE_BLOCK_OFFICIAL_PLAYLIST":
                        List officiallist = element["creatives"];
                        String officialTitle =
                            element["uiElement"]["subTitle"]["title"];
                        return SlideListPage(
                          recommendList: officiallist,
                          title: officialTitle,
                        );
                      case "HOMEPAGE_BLOCK_VIDEO_PLAYLIST":
                        List videoPlaylist = element["creatives"];
                        String videoPlayTitle =
                            element["uiElement"]["subTitle"]["title"];
                        return SlideListPage(
                          recommendList: videoPlaylist,
                          title: videoPlayTitle,
                        );
                      case "ADD_MENU_LIST":
                        return Container(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // 去到推荐单曲页
                                  DefaultProvider user =
                                      Provider.of<DefaultProvider>(context,
                                          listen: false);
                                  if (user.islogin) {
                                    Navigator.of(context)
                                        .pushNamed('/recommentsingle');
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(212, 59, 45, 0.78),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                              'images/default/icon_daily.png'),
                                          Transform.translate(
                                            offset: Offset(0, 2),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${DateTime.now().day}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      212, 59, 45, 0.78),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '每日推荐',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  this.getPersonFMlist();
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(212, 59, 45, 0.78),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Image.asset(
                                          'images/default/icon_radio.png'),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '私人FM',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(212, 59, 45, 0.78),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Image.asset(
                                        'images/default/icon_playlist.png'),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '歌单',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(212, 59, 45, 0.78),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Image.asset(
                                        'images/default/icon_rank.png'),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '排行榜',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/livepage',
                                    arguments: {
                                      "tagid": '',
                                      "typetitle": '推荐直播',
                                    },
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(212, 59, 45, 0.78),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Image.asset(
                                          'images/default/icon_look.png'),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '直播',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(212, 59, 45, 0.78),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Image.asset(
                                        'images/default/icon_pvo.png'),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '数字专辑',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      default:
                        return SizedBox();
                    }
                  },
                  itemCount: findMusicList.length,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ButtonPlayWight(),
              )
            ],
          ),
        ));
  }
}
