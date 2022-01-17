// 视频上下滑动页

import 'package:flutter/material.dart';
import 'package:netease_app/pages/video_page/mvdetail.dart';
import 'package:netease_app/pages/video_page/videodetail.dart';

class VideoPlayListPage extends StatefulWidget {
  var videoId;
  var type;
  VideoPlayListPage({Key? key, required this.videoId, this.type = 0})
      : super(key: key);

  @override
  _VideoPlayListPageState createState() =>
      _VideoPlayListPageState(videoId: this.videoId, type: this.type);
}

class _VideoPlayListPageState extends State<VideoPlayListPage> {
  var videoId;
  var type;
  _VideoPlayListPageState({required this.videoId, this.type = 0});
  var mvinfo;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return type == 0
        ? MvVideoPlayerDetail(
            videoId: videoId is int ? videoId : int.parse(videoId),
          )
        : VideoDetailWidget(
            videoId: videoId,
          );
  }
}
