import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/wight/custom_controls_widget.dart';

class VideoPlayUrlWigdet extends StatefulWidget {
  String mvurl;
  String title;
  VideoPlayUrlWigdet({Key? key, required this.mvurl, this.title = ''})
      : super(key: key);

  @override
  _VideoPlayUrlWigdetState createState() =>
      _VideoPlayUrlWigdetState(mvurl: this.mvurl);
}

class _VideoPlayUrlWigdetState extends State<VideoPlayUrlWigdet> {
  String mvurl;

  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();
  _VideoPlayUrlWigdetState({required this.mvurl});
  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, mvurl,
            cacheConfiguration: BetterPlayerCacheConfiguration(
              useCache: false,
            ));
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
              controlsConfiguration: BetterPlayerControlsConfiguration(),
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
    print('????????????dispose==========================');
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
