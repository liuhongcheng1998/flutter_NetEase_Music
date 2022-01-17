// 直播视频溜

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/wight/custom_controls_widget.dart';

class LiveUrlVideoPlayerWidget extends StatefulWidget {
  final String url;
  final String title;
  LiveUrlVideoPlayerWidget({Key? key, required this.url, this.title = ''})
      : super(key: key);

  @override
  _LiveUrlVideoPlayerWidgetState createState() =>
      _LiveUrlVideoPlayerWidgetState(url: this.url);
}

class _LiveUrlVideoPlayerWidgetState extends State<LiveUrlVideoPlayerWidget> {
  final String url;
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();
  _LiveUrlVideoPlayerWidgetState({required this.url});

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: false,
      ),
      liveStream: true,
    );
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          fit: BoxFit.contain,
          autoDetectFullscreenDeviceOrientation: true,
          aspectRatio: 16 / 9,
          autoPlay: true,
          fullScreenByDefault: false,
          autoDispose: true,
          expandToFill: true,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          deviceOrientationsOnFullScreen: [DeviceOrientation.landscapeRight],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            playerTheme: BetterPlayerTheme.custom,
            enableOverflowMenu: false,
            enablePlaybackSpeed: false,
            enableSkips: false,
            customControlsBuilder: (controller, onPlayerVisibilityChanged) =>
                BetterPlayerMaterialControls(
              controlsConfiguration: BetterPlayerControlsConfiguration(
                liveTextColor: Color.fromRGBO(212, 59, 45, 0.78),
              ),
              onControlsVisibilityChanged: onPlayerVisibilityChanged,
              name: widget.title,
            ),
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
  }

  @override
  void dispose() {
    _betterPlayerController.pause();
    _betterPlayerController.clearCache();
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(
        controller: _betterPlayerController,
        key: _betterPlayerKey,
      ),
    );
  }
}
