// 播放列表

import 'package:netease_app/model/songs.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Song> fetchAnotherSong(Song song);
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 3}) async {
    return [];
  }

  @override
  Future<Song> fetchAnotherSong(Song song) async {
    return song;
  }
}
