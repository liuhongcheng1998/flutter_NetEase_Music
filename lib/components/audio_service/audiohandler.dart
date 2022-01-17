// 音乐播放锁屏界面

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:netease_app/main.dart';
import 'package:netease_app/provider/play_song_model.dart';
import 'package:provider/provider.dart';

class AudioPlayerHandlerImpl extends BaseAudioHandler with SeekHandler {
  BuildContext context = navigatorKey.currentState!.overlay!.context;
  late PlaySongsModel model;
  late AudioPlayer _player;

  AudioPlayerHandlerImpl() {
    _init();
  }

  _init() async {
    model = Provider.of<PlaySongsModel>(context, listen: false);
    _player = model.player;
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() async {
    model = Provider.of<PlaySongsModel>(context, listen: false);
    _player = model.player;
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    print('到底拿到参数没有${model.curSong}');
    mediaItem.add(MediaItem(
      id: model.curSong.id.toString(),
      title: model.curSong.name,
      artist: model.curSong.artists,
      artUri: Uri.parse(model.curSong.picUrl),
      duration: model.curSong.timer,
    ));
    model.play();
  }

  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> skipToNext() async {}

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
