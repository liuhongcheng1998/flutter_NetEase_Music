// 当前播放歌曲
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

class PlayItemNotifier extends ValueNotifier<MediaItem> {
  PlayItemNotifier() : super(_initialValue);
  static const _initialValue = MediaItem(
      id: '', title: '', artist: '', album: '', extras: {'picUrl': ''});
}
