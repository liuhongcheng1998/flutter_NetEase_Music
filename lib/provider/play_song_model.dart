// // 音乐播放

// import 'dart:async';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:netease_app/http/request.dart';
// import 'package:netease_app/model/playtype.dart';
// import 'package:netease_app/model/songs.dart';
// import 'package:audioplayers/audioplayers.dart';

// class PlaySongsModel with ChangeNotifier {
// AudioPlayer _audioPlayer = AudioPlayer();
// List<Song> _songs = []; // 播放歌曲数组
// int curIndex = 0; // 播放的索引
// late Duration curSongDuration; // 时间
// StreamController<String> _curPositionController =
//     StreamController<String>.broadcast();

// late PlayerState _curState;

// late Duration _updateTime;

// Duration get updateTime => _updateTime;

// NextPlayType _nextPlayType = NextPlayType.sequence; // 播放模式

// List<Song> get allSongs => _songs; // 获取songs
// Song get curSong => _songs[curIndex]; // 获取现在展示的song
// Stream<String> get curPositionStream => _curPositionController.stream;

// PlayerState get playState => _curState;

// NextPlayType get nextPlayType => _nextPlayType;

// void setPlayType(NextPlayType type) {
//   _nextPlayType = type;
//   notifyListeners();
// }

// void init() {
//   _audioPlayer.setReleaseMode(ReleaseMode.STOP);
//   // 播放状态

//   _audioPlayer.onPlayerStateChanged.listen((state) {
//     _curState = state;
//     print(state);

//     /// 先做顺序播放
//     if (state == PlayerState.COMPLETED) {
//       if (_nextPlayType == NextPlayType.sequence) {
//         // 顺序播放
//         nextPlay();
//       } else if (_nextPlayType == NextPlayType.circulation) {
//         // 单曲循环
//       } else if (_nextPlayType == NextPlayType.random) {
//         // 随机播放
//       } else if (_nextPlayType == NextPlayType.heartbeat) {
//         // 心动模式
//       }
//     }
//     // 其实也只有在播放状态更新时才需要通知。
//     notifyListeners();
//   });
//   _audioPlayer.onDurationChanged.listen((d) {
//     curSongDuration = d;
//   });

//   // 当前播放进度监听
//   _audioPlayer.onAudioPositionChanged.listen((Duration p) {
//     // print(p);
//     _updateTime = p;
//     sinkProgress(p.inMilliseconds > curSongDuration.inMilliseconds
//         ? curSongDuration.inMilliseconds
//         : p.inMilliseconds);
//   });
// }

// // 歌曲进度
// void sinkProgress(int m) {
//   _curPositionController.sink.add('$m-${curSongDuration.inMilliseconds}');
// }

// // 播放一首歌
// void playSong(Song song) {
//   _songs.insert(curIndex, song);
//   print(_songs);
//   play();
// }

// // 播放很多歌
// void playSongs(List<Song> songs, {int index = 0}) {
//   this._songs = songs;
//   if (index != null) curIndex = index;
//   play();
// }

// // 添加歌曲
// void addSongs(List<Song> songs) {
//   this._songs.addAll(songs);
// }

// /// 播放
// void play() async {
//   var songId = this._songs[curIndex].id;
//   String url = await getSongUrl({"id": songId});
//   print(url);
//   if (url.isNotEmpty) {
//     await _audioPlayer.play(url);
//   }
// }

// // 播放下标歌
// void playInex(int index) async {
//   curIndex = index;
//   play();
// }

// /// 暂停、恢复
// void togglePlay() {
//   if (_audioPlayer.state == PlayerState.PAUSED) {
//     print("继续播放");
//     resumePlay();
//   } else {
//     print("暂停");
//     pausePlay();
//   }
// }

// // 暂停
// void pausePlay() {
//   _audioPlayer.pause();
// }

// /// 跳转到固定时间
// void seekPlay(int milliseconds) {
//   _audioPlayer.seek(Duration(milliseconds: milliseconds));
//   resumePlay();
// }

// /// 恢复播放
// void resumePlay() {
//   _audioPlayer.resume();
// }

// /// 下一首
// void nextPlay() {
//   if (curIndex >= _songs.length) {
//     curIndex = 0;
//   } else {
//     curIndex++;
//   }
//   play();
// }

// void prePlay() {
//   if (curIndex <= 0) {
//     curIndex = _songs.length - 1;
//   } else {
//     curIndex--;
//   }
//   play();
// }

// @override
// void dispose() {
//   super.dispose();
//   _curPositionController.close();
//   _audioPlayer.dispose();
// }
// }

// 音乐播放锁屏界面

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/playtype.dart';
import 'package:netease_app/model/songs.dart';

class PlaySongsModel extends BaseAudioHandler with SeekHandler, ChangeNotifier {
  List<Song> _songs = []; // 播放歌曲数组
  int curIndex = 0; // 播放的索引
  late Duration curSongDuration; // 时间
  final _player = AudioPlayer(); // 播放器

  // ignore: close_sinks
  StreamController<String> _curPositionController =
      StreamController<String>.broadcast();

  late PlayerState _curState;

  late Duration _updateTime;

  Duration get updateTime => _updateTime;

  NextPlayType _nextPlayType = NextPlayType.sequence; // 播放模式

  List<Song> get allSongs => _songs; // 获取songs
  Song get curSong => _songs[curIndex]; // 获取现在展示的song
  Stream<String> get curPositionStream => _curPositionController.stream;

  PlayerState get playState => _curState;

  NextPlayType get nextPlayType => _nextPlayType;

  AudioPlayer get player => _player;

  void setPlayType(NextPlayType type) {
    _nextPlayType = type;
    notifyListeners();
  }

  // 歌曲进度
  void sinkProgress(int m) {
    _curPositionController.sink.add('$m-${curSongDuration.inMilliseconds}');
  }

  /// Initialise our audio handler.
  PlaySongsModel() {
    curSongDuration = Duration();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.durationStream.listen((d) {
      curSongDuration = d!;
      notifyListeners();
    });
    _player.positionStream.listen((p) {
      _updateTime = p;
      sinkProgress(p.inMilliseconds > curSongDuration.inMilliseconds
          ? curSongDuration.inMilliseconds
          : p.inMilliseconds);
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      _curState = state;
      if (state.playing) {
        // 播放状态 这里表示是这种播放
      } else {
        // 这里表示是没有在播放
        switch (state.processingState) {
          case ProcessingState.idle:
            // 未加载
            break;
          case ProcessingState.loading:
            // 加载中
            break;
          case ProcessingState.buffering:
            // 缓冲
            break;
          case ProcessingState.ready:
            // 准备好可以播放
            break;
          case ProcessingState.completed:
            // 播放结束
            break;
        }
      }
      notifyListeners();
    });
  }

  Future<bool> getsongplay() async {
    var songId = this._songs[curIndex].id;
    String url = await getSongUrl({"id": songId});
    if (url.isNotEmpty) {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );
      // play();
      return true;
    } else {
      return false;
    }
  }

  // 播放一首歌
  Future<bool> playSong(Song song) async {
    print('收到的song$song');
    _songs.insert(curIndex, song); // 将播放添加到播放队列
    print('当前的song$_songs');
    // 这里是背景显示

    notifyListeners();
    return await getsongplay();
  }

  // 播放很多歌
  void playSongs(List<Song> songs, {int index = 0}) {
    this._songs = songs;
    // ignore: unnecessary_null_comparison
    if (index != null) curIndex = index;
    getsongplay();
  }

  // 添加歌曲
  void addSongs(List<Song> songs) {
    this._songs.addAll(songs);
  }

  // 播放下标歌
  void playInex(int index) async {
    curIndex = index;
    getsongplay();
  }

  /// 暂停、恢复
  void togglePlay() {
    if (_player.playing) {
      print("暂停");
      // pausePlay();
    } else {
      print("继续播放");
      // resumePlay();
    }
  }

  // 暂停
  void pausePlay() {
    _player.pause();
  }

  /// 跳转到固定时间
  void seekPlay(int milliseconds) {
    _player.seek(Duration(milliseconds: milliseconds));
  }

  /// 恢复播放
  void resumePlay() {
    _player.play();
  }

  /// 下一首
  void nextPlay() {
    if (curIndex >= _songs.length) {
      curIndex = 0;
    } else {
      curIndex++;
    }
    getsongplay();
  }

  void prePlay() {
    if (curIndex <= 0) {
      curIndex = _songs.length - 1;
    } else {
      curIndex--;
    }
    getsongplay();
  }

  @override
  Future<void> play() async {
    mediaItem.add(MediaItem(
      id: '1111111',
      title: '情非得已',
      artUri: Uri.parse(
          'http://p1.music.126.net/Shi7cRT1bDhwpVDM7AOFXg==/109951165265330616.jpg'),
      artist: '小孩',
      duration: Duration(milliseconds: 267232),
    ));
    _player.setAudioSource(AudioSource.uri(Uri.parse(
        'http://m7.music.126.net/20211222111605/640f9f1efa2056ba0294ef42840824ef/ymusic/0fd6/4f65/43ed/a8772889f38dfcb91c04da915b301617.mp3')));
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
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
