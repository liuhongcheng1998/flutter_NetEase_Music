// 播放列表缓存

import 'dart:convert';

import 'package:netease_app/model/songs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

Future<dynamic> setSongsList(List<Song> songlist) async {
  final com = Completer();

  final future = com.future;
  List<String> songstringlist = <String>[];

  songlist.forEach((element) {
    songstringlist.add(element.toString());
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('songlist', songstringlist);
    com.complete(true);
  } catch (e) {
    com.complete(false);
  }

  return future;
}

Future<dynamic> getSongsList() async {
  final com = Completer();
  final future = com.future;

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('songlist') ?? [];
    List<Song> songlist = [];
    values.forEach((element) {
      var songitem = jsonDecode(element);
      Song song = Song.fromJson(songitem);
      songlist.add(song);
    });
    com.complete(songlist);
  } catch (err) {
    com.complete([]);
  }

  return future;
}
