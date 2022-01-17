// 全局处理

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/songs.dart';
import 'package:netease_app/notifiers/play_button_notifier.dart';
import 'package:netease_app/notifiers/play_item_notifier.dart';
import 'package:netease_app/notifiers/progress_notifier.dart';
import 'package:netease_app/services/audio_handler.dart';
import 'package:netease_app/services/playlist_repository.dart';
import 'package:netease_app/services/service_locator.dart';

class PageManager {
  final currentSongTitleNotifier = PlayItemNotifier();
  final playlistNotifier = ValueNotifier<List>([]); // 播放列表
  final progressNotifier = ProgressNotifier(); // 时间进度条
  // final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true); // 是不是第一首歌
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true); // 是不是最后一首歌
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final _audioHandler = getIt<AudioPlayerHandler>();
  final isPersonFm = ValueNotifier<bool>(false); // 当前是否是私人fm
  final waitPersonFm = ValueNotifier<bool>(false);

  // 初始化
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchInitialPlaylist();
    final mediaItems = playlist
        .map((song) => MediaItem(
              id: song['id'] ?? '',
              album: song['album'] ?? '',
              title: song['title'] ?? '',
              extras: {'url': song['url']},
            ))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = MediaItem(id: '', title: '');
      } else {
        final newList = playlist;
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    // 监听播放状态
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      print(processingState);
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        // 加载中
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        // 没有播放
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        // 播放中
        playButtonNotifier.value = ButtonState.playing;
      } else if (isPlaying) {
        // playButtonNotifier.value = ButtonState.playing;
      } else {
        // 重置
        // print('重置触发');
        // _audioHandler.seek(Duration.zero);
        // _audioHandler.pause();
      }
    });
  }

  // 更新播放时间
  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      // print('播放时间$position');
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  // 更新缓冲位置
  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  // 更新总时长
  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  // 更新歌曲显示最新的歌曲
  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem!;
      print('Item$mediaItem');
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
    // if (isPersonFm.value) {
    //   // 如果这个是私人Fm的话 当播放的这首歌是最后一首歌的时候,遇到获取新的歌曲添加到歌单
    //   print(
    //       'object============${isLastSongNotifier.value}===========${waitPersonFm.value}');
    //   if (isLastSongNotifier.value && !waitPersonFm.value) {
    //     waitPersonFm.value = true;
    //     print('触发===============');
    //     this.getPersonFmList();
    //   }
    // }
  }

  // 改变是否是私人Fm
  void changeIsPersonFm(bool personFm) {
    isPersonFm.value = personFm;
  }

  // 获取私人Fm
  Future<void> getPersonFmList() async {
    Map<String, dynamic> params = {
      "timestamp": '${DateTime.now().microsecondsSinceEpoch}',
    };
    getPersonaFm(params).then((value) {
      if (value["code"] == 200) {
        List<Song> playsongslist = <Song>[];
        value["data"].forEach((element) {
          playsongslist.add(Song(
            element["id"],
            Duration(milliseconds: element["duration"]),
            name: element["name"],
            picUrl: element["album"]["picUrl"],
            artists: createArtistString(element["artists"]),
          ));
        });
        addSongs(playsongslist);
      }
    });
  }

  createArtistString(List list) {
    List artistString = [];
    list.forEach((element) {
      artistString.add(element["name"]);
    });
    return artistString.join('/');
  }

  Future<void> play() async {
    await _audioHandler.readySongUrl();
  }

  Future<void> resumePlay() async {
    await _audioHandler.play();
  }

  sinkProgress(int timer) async {
    final oldState = progressNotifier.value;
    progressNotifier.value = ProgressBarState(
      current: Duration(milliseconds: timer),
      buffered: oldState.buffered,
      total: oldState.total,
    );
  }

  void pasue() {
    _audioHandler.pause();
  }

  void togglePlay() {
    if (playButtonNotifier.value == ButtonState.paused) {
      // 执行播放
      resumePlay();
    } else {
      // 执行暂停
      pasue();
    }
  }

  void playInex(int index) async {
    await _audioHandler.playIndex(index);
  }

  void seek(Duration position) => _audioHandler.seek(position); // 时间跳转
  void previous() => _audioHandler.skipToPrevious(); // 上一首
  void next() => _audioHandler.skipToNext(); // 下一首
  void repeat() {}
  void shuffle() {}
  // 添加一首歌
  Future<void> add(Song song) async {
    final songRepository = getIt<PlaylistRepository>();

    final songitem = await songRepository.fetchAnotherSong(song);
    final mediaItem = MediaItem(
      id: songitem.id.toString(),
      album: '',
      artist: songitem.artists,
      duration: songitem.timer,
      title: songitem.name,
      artUri: Uri.parse(songitem.picUrl),
      extras: {
        'picUrl': songitem.picUrl,
      },
    );
    _audioHandler.addQueueItem(mediaItem);
  }

// 添加一个列表到播放列表
  Future<void> addSongs(List<Song> songlist, {int index = 0}) async {
    final List<MediaItem> mediaItems = <MediaItem>[];
    songlist.forEach((element) {
      mediaItems.add(MediaItem(
        id: element.id.toString(),
        album: '',
        artist: element.artists,
        duration: element.timer,
        title: element.name,
        artUri: Uri.parse(element.picUrl),
        extras: {
          'picUrl': element.picUrl,
        },
      ));
    });
    await _audioHandler.addQueueItems(mediaItems);
  }

  Future<void> changesonglistplay(List<Song> list, {int index = 0}) async {
    final List<MediaItem> mediaItems = <MediaItem>[];
    list.forEach((element) {
      mediaItems.add(MediaItem(
        id: element.id.toString(),
        album: '',
        artist: element.artists,
        duration: element.timer,
        title: element.name,
        artUri: Uri.parse(element.picUrl),
        extras: {
          'picUrl': element.picUrl,
        },
      ));
    });
    await _audioHandler.changeQueueLists(mediaItems, index: index);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  Future<void> changelist(list) async {}

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
