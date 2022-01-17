// 另外一种播放器

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

import 'package:fijkplayer_skin/schema.dart' show VideoSourceFormat;
import 'package:netease_app/components/live/custom_fijk_skin.dart';

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool drawerBtn = false;
  @override
  bool nextBtn = false;
  @override
  bool speedBtn = false;
  @override
  bool topBar = true;
  @override
  bool lockBtn = true;
  @override
  bool autoNext = false;
  @override
  bool bottomPro = true;
  @override
  bool stateAuto = false;
  @override
  bool isAutoPlay = true;
}

class LiveFijkPlayerWidget extends StatefulWidget {
  final String url;
  final String title;
  LiveFijkPlayerWidget({Key? key, required this.url, this.title = ''})
      : super(key: key);

  @override
  _LiveFijkPlayerWidgetState createState() =>
      _LiveFijkPlayerWidgetState(url: this.url);
}

class _LiveFijkPlayerWidgetState extends State<LiveFijkPlayerWidget> {
  final String url;
  _LiveFijkPlayerWidgetState({required this.url});
  FijkPlayer fplayer = FijkPlayer();
  int _curTabIdx = 0;
  int _curActiveIdx = 0;
  ShowConfigAbs vCfg = PlayerShowConfig();
  VideoSourceFormat? _videoSourceTabs;
  Map<String, List<Map<String, dynamic>>> videoList = {};
  @override
  void initState() {
    super.initState();
    List dd = url.split('?');
    String newurl = dd[0]
        .toString()
        .replaceAll('douyucdn2', 'douyucdn')
        .replaceAll('_2000', '_4000');
    newurl = newurl.substring(newurl.indexOf('.'), newurl.length);
    newurl = 'http://dyscdnali1' + newurl;
    fplayer.setDataSource(newurl, autoPlay: true);
    fplayer.addListener(_fijkValueListener);
    videoList = {
      "video": [
        {
          "name": widget.title,
          "list": [
            {
              "url": newurl,
              "name": widget.title,
            },
          ]
        },
      ]
    };
    _videoSourceTabs = VideoSourceFormat.fromJson(videoList);
  }

  _fijkValueListener() async {
    await fplayer.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await FijkPlugin.keepScreenOn(true);
  }

  @override
  void dispose() {
    fplayer.removeListener(_fijkValueListener);
    fplayer.release();
    fplayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FijkView(
        player: fplayer,
        fit: FijkFit.contain,
        fsFit: FijkFit.contain,
        color: Colors.black,
        panelBuilder: (player, data, context, viewSize, texturePos) {
          return CustomFijkPanel(
            player: player,
            viewSize: viewSize,
            texturePos: texturePos,
            pageContent: context,
            // 标题 当前页面顶部的标题部分
            playerTitle: widget.title,
            // 当前视频源tabIndex
            curTabIdx: _curTabIdx,
            // 当前视频源activeIndex
            curActiveIdx: _curActiveIdx,
            // 显示的配置
            showConfig: vCfg,
            // json格式化后的视频数据
            videoFormat: _videoSourceTabs,
          );
        },
      ),
    );
  }
}
