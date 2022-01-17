import 'package:flutter/material.dart';

import 'package:netease_app/http/request.dart';
import 'package:netease_app/notifiers/progress_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/pages/playsongs/changlyric.dart';
import 'package:netease_app/pages/playsongs/mylyric_page.dart';

import 'package:netease_app/style/textstyle.dart';
import 'package:mmoo_lyric/lyric_controller.dart';
import 'package:mmoo_lyric/lyric_util.dart';
import 'package:mmoo_lyric/lyric_widget.dart';
import 'dart:async';

import 'package:perfect_volume_control/perfect_volume_control.dart';

class LyricPage extends StatefulWidget {
  final PageManager model;

  LyricPage(this.model);

  @override
  _LyricPageState createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage> with TickerProviderStateMixin {
  late int curSongId;
  var lyrics;
  late LyricController controller = LyricController(vsync: this);
  //是否显示选择器
  bool showSelect = false;
  var songLyc;
  late double volumeValue;
  late StreamSubscription<double> _subscription;
  @override
  void initState() {
    super.initState();
    curSongId = int.parse(widget.model.currentSongTitleNotifier.value.id);
    _request();
    volumeValue = 0;
    controller.addListener(() {});
    getVolumes();
    _subscription = PerfectVolumeControl.stream.listen((value) {
      this.setState(() {
        volumeValue = value;
      });
    });
  }

  getVolumes() async {
    volumeValue = await PerfectVolumeControl.getVolume();
  }

  changeSongs(Duration? secound) {
    widget.model.seek(secound!);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _request() async {
    lyrics = await getsongsLyricData({"id": curSongId.toString()});
    setState(() {
      songLyc = lyrics["lrc"]["lyric"];
    });
  }

  createIcons() {
    if (volumeValue == 0) {
      return Icon(
        Icons.volume_mute_rounded,
        color: Colors.white,
      );
    } else if (volumeValue <= 0.5) {
      return Icon(
        Icons.volume_down_rounded,
        color: Colors.white,
      );
    } else {
      return Icon(
        Icons.volume_up_rounded,
        color: Colors.white,
      );
    }
  }

  setvolumeValue(double value) {
    PerfectVolumeControl.setVolume(value);
  }

  Widget buildProgress(BuildContext context, double volume) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      height: 50,
      color: Colors.transparent,
      child: Row(
        children: [
          createIcons(),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 5,
                ),
              ),
              child: Slider(
                value: volumeValue,
                onChanged: (data) async {
                  this.setState(() {
                    volumeValue = data;
                  });
                },
                onChangeStart: (data) {},
                onChangeEnd: (data) async {
                  await setvolumeValue(data);
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                min: 0,
                max: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 当前歌的id变化之后要重新获取歌词

    if (curSongId !=
        int.parse(widget.model.currentSongTitleNotifier.value.id)) {
      // lyrics = [];
      curSongId = int.parse(widget.model.currentSongTitleNotifier.value.id);
      _request();
    }

    var lyrics = LyricUtil.formatLyric(songLyc);
    return lyrics == null
        ? Container(
            alignment: Alignment.center,
            child: Text(
              '歌词加载中...',
              style: commonWhiteTextStyle,
            ),
          )
        : Column(
            // alignment: Alignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(context, volumeValue),
              Expanded(
                child: Container(
                  child: Center(
                    child: ValueListenableBuilder<ProgressBarState>(
                      valueListenable: widget.model.progressNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        var curTime =
                            double.parse('${value.current.inMilliseconds}');
                        // controller.progress =
                        //     Duration(milliseconds: curTime.toInt());
                        return MyLyricWidget(
                          callback: (Duration? value) {
                            changeSongs(value);
                          },
                          lyrics: lyrics,
                          progress: Duration(milliseconds: curTime.toInt()),
                          lyricStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                          currLyricStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          draggingLyricStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),

                    // child: LyricWidget(
                    //   lyricGap: 20,
                    //   size: Size(double.infinity, double.infinity),
                    //   lyrics: lyrics,
                    //   controller: controller,
                    //   lyricStyle: TextStyle(
                    //     color: Colors.white54,
                    //     fontSize: 16,
                    //   ),
                    //   currLyricStyle: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //   ),
                    //   draggingLyricStyle: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //   ),
                    // ),
                  ),
                ),
                flex: 1,
              ),
              // ValueListenableBuilder<ProgressBarState>(
              //   valueListenable: widget.model.progressNotifier,
              //   builder: (BuildContext context, value, Widget? child) {
              //     var curTime =
              //         double.parse('${value.current.inMilliseconds}');
              //     controller.progress =
              //         Duration(milliseconds: curTime.toInt());
              //     return ChangeLyricWight(
              //       isshow: controller.isDragging,
              //       callback: () {
              //         changeSongs();
              //       },
              //     );
              //   },
              // ),
            ],
          );
  }
}
