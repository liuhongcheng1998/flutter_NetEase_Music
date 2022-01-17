// 发现页

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

class FindMusicPage extends StatefulWidget {
  FindMusicPage({Key? key}) : super(key: key);

  @override
  _FindMusicPageState createState() => _FindMusicPageState();
}

class _FindMusicPageState extends State<FindMusicPage>
    with SingleTickerProviderStateMixin {
  var bannerList; // banner
  // ignore: non_constant_identifier_names
  var search_tips;
  var findMusicList; // 发现页全部数据
  late EasyRefreshController _controller;
  late AnimationController controller;

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

  Future _getsearchlist() async {
    var data = await getHotSearchList();
    if (data["code"] == 200) {
      return data["result"]["hots"];
    } else {
      return [];
    }
  }

  Future _findMusicAllList() async {
    var data = await getFindMusicAll({});
    if (data["code"] == 200) {
      return data["data"]["blocks"];
    } else {
      return [];
    }
  }

  String _createStringList(item) {
    return item["first"].toString();
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
                    findMusicList = _findMusicAllList();
                    _controller.resetLoadState();
                  });
                },
                child: ListView(
                  children: [
                    FutureBuilder(
                      future: findMusicList,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        // print("数据${snapshot.data}");
                        if (snapshot.hasError) {
                          return Container(
                            height: 150,
                          );
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Container(
                              height: 150,
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            List bannerList = [];
                            List playlist = [];
                            List newsonglist = [];
                            List calendarlist = [];
                            List videoList = [];
                            List slideplaylist = [];
                            String slideTitle = '';
                            List officiallist = [];
                            String officialTitle = '';
                            List videoPlaylist = [];
                            String videoPlayTitle = '';
                            var personality;
                            snapshot.data.forEach((element) {
                              switch (element["blockCode"]) {
                                case "HOMEPAGE_BANNER":
                                  // 轮播图
                                  bannerList = element["extInfo"]["banners"];
                                  break;
                                case "HOMEPAGE_BLOCK_PLAYLIST_RCMD":
                                  // 推荐歌单
                                  playlist = element["creatives"];
                                  break;
                                case "HOMEPAGE_BLOCK_STYLE_RCMD":
                                  // 个性推荐
                                  personality = element;
                                  break;
                                case "HOMEPAGE_BLOCK_NEW_ALBUM_NEW_SONG":
                                  newsonglist = element["creatives"];
                                  break;
                                case "HOMEPAGE_MUSIC_CALENDAR":
                                  calendarlist = element["creatives"];
                                  break;
                                case "HOMEPAGE_MUSIC_MLOG":
                                  videoList = element["extInfo"];
                                  break;
                                case "HOMEPAGE_BLOCK_MGC_PLAYLIST":
                                  slideplaylist = element["creatives"];
                                  slideTitle =
                                      element["uiElement"]["subTitle"]["title"];
                                  break;
                                case "HOMEPAGE_BLOCK_OFFICIAL_PLAYLIST":
                                  officiallist = element["creatives"];
                                  officialTitle =
                                      element["uiElement"]["subTitle"]["title"];
                                  break;
                                case "HOMEPAGE_BLOCK_VIDEO_PLAYLIST":
                                  videoPlaylist = element["creatives"];
                                  videoPlayTitle =
                                      element["uiElement"]["subTitle"]["title"];
                                  break;
                                default:
                                  break;
                              }
                            });

                            return Column(
                              children: [
                                // banner
                                Container(
                                  height: 150,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  child: Swiper(
                                    loop: true,
                                    autoplay: true,
                                    itemBuilder: (context, int index) {
                                      return Container(
                                        padding:
                                            EdgeInsets.fromLTRB(20, 0, 20, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                ),
                                // =============菜单栏============
                                Container(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  212, 59, 45, 0.78),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Image.asset(
                                                'images/default/icon_daily.png'),
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
                                      Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  212, 59, 45, 0.78),
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                      Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  212, 59, 45, 0.78),
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                              color: Color.fromRGBO(
                                                  212, 59, 45, 0.78),
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                      Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(
                                                  212, 59, 45, 0.78),
                                              borderRadius:
                                                  BorderRadius.circular(50),
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
                                    ],
                                  ),
                                ),
                                // ===========推荐歌单======
                                RecommendListPage(
                                  recommendList: playlist,
                                ),
                                // =============个性推荐===========
                                PersonalityPage(
                                  personalityInfo: personality,
                                ),
                                // 新歌
                                NewSongPage(
                                  newSongList: newsonglist,
                                ),
                                // ======音乐日历===========
                                MusicCalenderPage(
                                  calenderList: calendarlist,
                                ),
                                // ========精选音乐视频==========
                                SelectedVideoPage(
                                  videoList: videoList,
                                ),
                                SlideListPage(
                                  recommendList: slideplaylist,
                                  title: slideTitle,
                                ),
                                SlideListPage(
                                  recommendList: officiallist,
                                  title: officialTitle,
                                ),
                                SlideListPage(
                                  recommendList: videoPlaylist,
                                  title: videoPlayTitle,
                                ),
                                SizedBox(
                                  height: 40,
                                )
                              ],
                            );
                          case ConnectionState.none:
                          default:
                            return Container(
                              height: 150,
                            );
                        }
                      },
                    ),
                  ],
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
