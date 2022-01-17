// 歌曲进度条
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:netease_app/notifiers/progress_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/style/textstyle.dart';

class SongProgressWidget extends StatelessWidget {
  final PageManager model;

  SongProgressWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: model.progressNotifier,
      builder: (context, value, child) {
        var curTime = double.parse('${value.current.inMilliseconds}');
        var curTimeStr =
            DateUtil.formatDateMs(curTime.toInt(), format: "mm:ss");
        if (curTime >= value.total.inMilliseconds) {
          return buildProgress(0, "0", "00:00");
        }
        return buildProgress(
            curTime, value.total.inMilliseconds.toString(), curTimeStr);
      },
    );
  }

  Widget buildProgress(double curTime, String totalTime, String curTimeStr) {
    return Container(
      height: 25,
      child: Row(
        children: <Widget>[
          Text(
            curTimeStr,
            style: smallWhiteTextStyle,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 5,
                ),
              ),
              child: Slider(
                value: curTime,
                onChanged: (data) {
                  model.sinkProgress(data.toInt());
                },
                onChangeStart: (data) {
                  model.pasue();
                },
                onChangeEnd: (data) {
                  model.seek(Duration(milliseconds: data.toInt()));
                  model.resumePlay();
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                min: 0,
                max: double.parse(totalTime),
              ),
            ),
          ),
          Text(
            DateUtil.formatDateMs(int.parse(totalTime), format: "mm:ss"),
            style: smallWhite30TextStyle,
          ),
        ],
      ),
    );
  }
}
