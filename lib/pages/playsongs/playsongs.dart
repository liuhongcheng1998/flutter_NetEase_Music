// 播放内页

import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/widget_img_menu.dart';
import 'package:netease_app/notifiers/play_button_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/pages/playsongs/lyric_page.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:netease_app/utils/number_utils.dart';
import 'package:netease_app/wight/lonelyPlanet.dart';
import 'package:netease_app/wight/songProgress.dart';
import 'package:netease_app/wight/songbuttonmenu.dart';
import 'package:netease_app/wight/widget_future_builder.dart';
import 'package:provider/provider.dart';

class PlaySongsPage extends StatefulWidget {
  PlaySongsPage({Key? key}) : super(key: key);

  @override
  _PlaySongsPageState createState() => _PlaySongsPageState();
}

class _PlaySongsPageState extends State<PlaySongsPage>
    with TickerProviderStateMixin {
  int switchIndex = 0; //用于切换歌词
  late AnimationController controller; // 旋转动画

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(seconds: 20), vsync: this); // 初始化旋转动画
    controller.addStatusListener((status) {
      // print(status);
      if (status == AnimationStatus.completed) {
        // 如果转完一圈过后继续转
        controller.reset();
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  getComments(context, params) async {
    var data = await getSongsComment(params);
    if (data["code"] == 200) {
      return data["data"];
    } else {
      return null;
    }
  }

  changeislike(bool islike, id, DefaultProvider user) async {
    Map<String, dynamic> params = {
      "id": '$id',
      "like": islike,
    };
    changLikeSong(params).then((value) {
      if (value["code"] == 200) {
        if (islike) {
          // 这里是添加
          user.changefavsong(true, id);
        } else {
          // 这里是移除
          user.changefavsong(false, id);
        }
      }
    });
  }

  Widget buildSongsHandle(PageManager model) {
    return Consumer<DefaultProvider>(
      builder: (context, user, child) {
        String id = model.currentSongTitleNotifier.value.id;
        List userFav = user.userfavoriteSong;
        bool isfav = false;
        if (userFav.isNotEmpty) {
          isfav = userFav.any((element) => '$element' == id);
        }
        return Container(
          height: 100,
          child: Row(
            children: <Widget>[
              ImageMenuWidget(
                isfav
                    ? 'images/default/icon_liked.png'
                    : 'images/default/icon_dislike.png',
                40,
                onTap: () {
                  changeislike(!isfav, id, user);
                },
              ),
              ImageMenuWidget(
                'images/default/icon_song_download.png',
                40,
                onTap: () {},
              ),
              ImageMenuWidget(
                'images/default/bfc.png',
                40,
                onTap: () {},
              ),
              // ImageMenuWidget(
              //   'images/default/icon_song_comment.png',
              //   40,
              //   onTap: () {},
              // ),
              CustomFutureBuilder(
                futureFunc: getComments,
                params: {
                  "id": '${model.currentSongTitleNotifier.value.id}',
                  'type': "0"
                },
                loadingWidget: ImageMenuWidget(
                  'images/default/icon_song_comment.png',
                  40,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/songcomment',
                      arguments: model.currentSongTitleNotifier.value,
                    );
                  },
                ),
                builder: (context, data) {
                  data as Map;
                  return Container(
                    width: 80,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/songcomment',
                          arguments: model.currentSongTitleNotifier.value,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'images/default/icon_song_comment.png',
                            width: 40,
                            height: 40,
                          ),
                          Positioned(
                            left: 42,
                            bottom: 21,
                            child: Container(
                              width: 80,
                              child: Text(
                                '${NumberUtils.formatNum(data["totalCount"])}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              ImageMenuWidget(
                'images/default/icon_song_more.png',
                40,
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: model.playButtonNotifier,
      builder: (context, playState, child) {
        bool showplanet = true;
        if (playState == ButtonState.playing) {
          // 如果当前状态是在播放当中，则唱片一直旋转，
          controller.forward();
          showplanet = true;
        } else {
          controller.stop();
          showplanet = false;
        }

        return ValueListenableBuilder<MediaItem>(
          valueListenable: model.currentSongTitleNotifier,
          builder: (context, curSong, child) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Image.network(
                    '${curSong.extras!['picUrl']}?param=200y300',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                  ClipRect(
                    // 这个必须有不然会全部模糊
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaY: 50,
                        sigmaX: 50,
                      ),
                      child: Container(),
                    ),
                  ),
                  AppBar(
                    centerTitle: true,
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    iconTheme: IconThemeData(color: Colors.white),
                    backgroundColor: Colors.transparent,
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          curSong.title,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          '${curSong.artist}',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          top: kToolbarHeight +
                              MediaQuery.of(context).padding.top),
                      child: Column(
                        children: [
                          // 中间部分 分封页和歌词页
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  if (switchIndex == 0) {
                                    switchIndex = 1;
                                  } else {
                                    switchIndex = 0;
                                  }
                                });
                              },
                              child: IndexedStack(
                                index: switchIndex,
                                children: [
                                  // 封面
                                  Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                            margin: EdgeInsets.only(top: 100),
                                            alignment: Alignment.center,
                                            height: 260,
                                            width: 260,
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: showplanet
                                                      ? LonelyPlanet()
                                                      : SizedBox(),
                                                ),
                                                RotationTransition(
                                                  turns: controller,
                                                  child: Stack(
                                                    children: [
                                                      Image.asset(
                                                        'images/default/bet.png',
                                                        width: 260,
                                                        height: 260,
                                                      ),
                                                      Container(
                                                          width: 260,
                                                          height: 260,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Hero(
                                                            tag: "playing",
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          260),
                                                              child: curSong
                                                                      .extras![
                                                                          'picUrl']
                                                                      .startsWith(
                                                                          'http')
                                                                  ? Image
                                                                      .network(
                                                                      '${curSong.extras!['picUrl']}?param=200y200',
                                                                      width:
                                                                          180,
                                                                      height:
                                                                          180,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.asset(
                                                                      curSong.extras![
                                                                          'picUrl'],
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                    ),
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      )
                                    ],
                                  ),
                                  // 歌词页
                                  LyricPage(model),
                                ],
                              ),
                            ),
                            // flex: 1,
                          ),
                          model.isPersonFm.value
                              ? SizedBox()
                              : buildSongsHandle(model),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0, left: 15, right: 15, bottom: 15),
                            child: SongProgressWidget(model),
                          ),
                          PlayBottomMenuWidget(model),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                      // height: 400,
                      // color: Colors.black,
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
