// 定义音频播放器背景

// ignore_for_file: unused_element, unnecessary_null_comparison

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:netease_app/http/request.dart';
// ignore: unused_import
import 'package:netease_app/model/playtype.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';

abstract class AudioPlayerHandler implements AudioHandler {
  // 添加公共方法
  Future<void> changeQueueLists(List<MediaItem> list, {int index = 0});
  Future<void> readySongUrl();
  Future<void> playIndex(int index);
  Future<void> addFmItems(List<MediaItem> mediaItems, bool isAddcurIndex);
}

Future<AudioPlayerHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: '网易云音乐',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler
    with SeekHandler
    implements AudioPlayerHandler {
  final _player = AudioPlayer(); // 播放器
  final _playlist = ConcatenatingAudioSource(children: []); // 播放列表
  final _songlist = <Song>[]; // 这个是播放列表
  int _curIndex = 0; // 播放列表索引

  MyAudioHandler() {
    // 初始化
    // _loadEmptyPlaylist(); // 加载播放列表
    _notifyAudioHandlerAboutPlaybackEvents(); // 背景状态更改
    _listenForDurationChanges(); // 当时间更改时更新背景
    _listenPlayEnd();
    // _listenForCurrentSongIndexChanges(); // 这个也是改背景
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.id),
      tag: mediaItem,
    );
  }

  Future<void> _loadEmptyPlaylist() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("错误:$e");
    }
  }

  void _listenPlayEnd() {
    _player.playerStateStream.listen((state) {
      if (state.playing) {
      } else {}
      switch (state.processingState) {
        case ProcessingState.idle:
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.buffering:
          break;
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          skipToNext();
          break;
      }
    });
  }

  void _listenForDurationChanges() {
    // 当时间发送变化时(也就是意味着歌曲发送变化) 这个是更新时间
    _player.durationStream.listen((duration) {
      // final index = _player.currentIndex; // 当前播放下标
      final newQueue = queue.value;
      if (_curIndex == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[_curIndex];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[_curIndex] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _curIndex,
      ));
    });
  }

  // void _listenForCurrentSongIndexChanges() {
  //   _player.currentIndexStream.listen((index) {
  // final playlist = queue.value;
  // if (index == null || playlist.isEmpty) return;
  // mediaItem.add(playlist[index]);
  //   });
  // }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSource = mediaItems.map(_futterSongItem);
    if (_songlist.length > 0) {
      // 判断当前歌曲的位置是否是处于最后一位

      _songlist.insertAll(_curIndex + 1, audioSource.toList());

      final newQueue = queue.value..insertAll(_curIndex + 1, mediaItems);
      // _curIndex++;
      queue.add(newQueue);
    } else {
      _songlist.insertAll(_curIndex, audioSource.toList());
      final newQueue = queue.value..insertAll(_curIndex, mediaItems);
      queue.add(newQueue);
    }
  }

  // 私人Fm的添加
  @override
  Future<void> addFmItems(List<MediaItem> mediaItems, bool isadd) async {
    final audioSource = mediaItems.map(_futterSongItem);
    if (_songlist.length > 0) {
      // 判断当前歌曲的位置是否是处于最后一位

      _songlist.insertAll(_curIndex + 1, audioSource.toList());

      final newQueue = queue.value..insertAll(_curIndex + 1, mediaItems);
      if (isadd) {
        _curIndex++;
      }
      queue.add(newQueue);
    } else {
      _songlist.insertAll(_curIndex, audioSource.toList());
      final newQueue = queue.value..insertAll(_curIndex, mediaItems);
      queue.add(newQueue);
    }
  }

  Song _futterSongItem(MediaItem mediaItem) {
    return Song(
      int.parse(mediaItem.id),
      mediaItem.duration!,
      artists: mediaItem.artist ?? '',
      picUrl: mediaItem.extras?["picUrl"] ?? '',
      name: mediaItem.title,
    );
  }

  @override
  Future<void> changeQueueLists(List<MediaItem> mediaitems,
      {int index = 0}) async {
    // 这里是替换播放列表
    final audioSource = mediaitems.map(_futterSongItem);
    // _playlist.clear();
    // _playlist.addAll(audioSource.toList()); // 添加到播放列表

    _songlist.clear();
    _songlist.addAll(audioSource.toList());
    _curIndex = index; // 更换了播放列表，将索引归0

    // notify system
    queue.value.clear();
    final newQueue = queue.value..addAll(mediaitems);
    queue.add(newQueue); // 添加到背景播放列表
  }

  @override
  Future<void> playIndex(int index) async {
    // 接收到下标
    _curIndex = index;
    readySongUrl();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    if (_songlist.length > 0) {
      // 判断当前歌曲的位置是否是处于最后一位
      _songlist.insert(_curIndex + 1, _futterSongItem(mediaItem));
      final newQueue = queue.value..insert(_curIndex + 1, mediaItem);
      _curIndex++;
      queue.add(newQueue);
    } else {
      _songlist.insert(_curIndex, _futterSongItem(mediaItem));
      final newQueue = queue.value..insert(_curIndex, mediaItem);
      queue.add(newQueue);
    }

    // notify system
  }

  @override
  Future<void> readySongUrl() async {
    // 这里是获取歌曲url
    var song = this._songlist[_curIndex];
    String url = await getSongUrl({"id": '${song.id}'});
    if (url.isNotEmpty) {
      // 加载音乐
      url = url.replaceFirst('http', 'https');
      try {
        await _player.setAudioSource(AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: '${song.id}',
            title: song.name,
            artist: song.artists,
            duration: song.timer,
            artUri: Uri.parse(song.picUrl),
          ),
        ));
      } catch (e) {
        print('error======$e');
      }
      // 这里需要重新更新一次
      final playlist = queue.value;
      if (_curIndex == null || playlist.isEmpty) return;
      mediaItem.add(playlist[_curIndex]);

      play(); // 播放
    }
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // 当触发播放下一首
    if (_curIndex >= _songlist.length - 1) {
      _curIndex = 0;
    } else {
      _curIndex++;
    }
    // 然后触发获取url
    readySongUrl();
    final model = getIt<PageManager>();
    print('触发播放下一首');
    if (model.isPersonFm.value) {
      // 如果是私人fm
      print('私人fm========$_curIndex');
      if (_curIndex == _songlist.length - 1) {
        // 判断如果是最后一首
        print('触发');
        model.getPersonFmList();
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_curIndex <= 0) {
      _curIndex = _songlist.length - 1;
    } else {
      _curIndex--;
    }
    readySongUrl();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
