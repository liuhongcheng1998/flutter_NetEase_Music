import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/components/bottom_sheet/musiclist_sheet.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/notifiers/play_button_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';

class ButtonPlayWight extends StatefulWidget {
  ButtonPlayWight({Key? key}) : super(key: key);

  @override
  _ButtonPlayWightState createState() => _ButtonPlayWightState();
}

class _ButtonPlayWightState extends State<ButtonPlayWight> {
  // getshowButton(PageManager model) {
  //   return
  // }

  _showBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false, // 全屏还是半屏
        isDismissible: true, // 是否可以点击外部执行关闭
        context: context,
        enableDrag: true, // 是否允许手动关闭
        builder: (BuildContext context) {
          return MusicListWidget();
        });
  }

  @override
  Widget build(BuildContext context) {
    final model = getIt<PageManager>();
    return Container(
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            color: Colors.white),
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(vertical: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 20, right: 20),
          height: 50,
          alignment: Alignment.center,
          child: ValueListenableBuilder<List>(
            valueListenable: model.playlistNotifier,
            builder: (context, value, child) {
              Widget childs;
              if (value.isEmpty) {
                // 播放列表等于空
                childs = TextButton(
                    onPressed: () async {
                      await model.add(Song(
                        33894312,
                        Duration(microseconds: 267232),
                        artists: '群星',
                        picUrl:
                            'https://p2.music.126.net/cpoUinrExafBHL5Nv5iDHQ==/109951166361218466.jpg',
                        name: '情非得已(童音版)',
                      ));
                      await model.play();
                    },
                    child: Text('暂无正在播放的歌曲'));
              } else {
                // 说明有东西存在
                childs = GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => {Navigator.of(context).pushNamed('/playsongs')},
                  child: Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<MediaItem>(
                          valueListenable: model.currentSongTitleNotifier,
                          builder: (context, value, child) {
                            return Row(
                              children: [
                                Transform(
                                  transform:
                                      Matrix4.translationValues(0, -8, 0),
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(45),
                                    ),
                                    child: Center(
                                      child: Hero(
                                        tag: "playing",
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(45),
                                          child: value.extras?["picUrl"].isEmpty
                                              ? Container(
                                                  width: 30,
                                                  height: 30,
                                                  child: LoadingIndicator(
                                                    indicatorType: Indicator
                                                        .ballClipRotatePulse,
                                                    colors: const [
                                                      Colors.red,
                                                      Color(0xFFFFE0B2),
                                                    ],
                                                    strokeWidth: 1,
                                                    backgroundColor:
                                                        Colors.black,
                                                    pathBackgroundColor:
                                                        Colors.black,
                                                  ),
                                                )
                                              : Image.network(
                                                  value.extras?['picUrl'] +
                                                      '?param=45y45',
                                                  fit: BoxFit.cover,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: value.title,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87),
                                        ),
                                        TextSpan(
                                          text: ' - ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black38),
                                        ),
                                        TextSpan(
                                          text: value.artist ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  flex: 1,
                                ),
                              ],
                            );
                          },
                        ),
                        flex: 1,
                      ),
                      ValueListenableBuilder<ButtonState>(
                        valueListenable: model.playButtonNotifier,
                        builder: (context, value, child) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (value == ButtonState.paused) {
                                    model.resumePlay();
                                  } else {
                                    model.pasue();
                                  }
                                },
                                child: Image.asset(
                                  value == ButtonState.playing
                                      ? 'images/default/pause.png'
                                      : 'images/default/play.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              // 列表
                              GestureDetector(
                                onTap: () {
                                  _showBottomSheet();
                                },
                                child: Image.asset(
                                  'images/default/list.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                );
              }
              return childs;
            },
          ),
        ),
      ),
    );
  }
}
