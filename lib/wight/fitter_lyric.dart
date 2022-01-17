import 'dart:convert';

class Lyric {
  String? lyric;
  Duration? startTime;
  Duration? endTime;
  bool isRemark;

  Lyric({this.lyric, this.startTime, this.endTime, this.isRemark = false});

  @override
  String toString() {
    return jsonEncode(toJson(this));
  }

  Lyric fromJson(Map json) {
    Lyric data = Lyric();
    if (json['lyric'] != null) {
      data.lyric = json['lyric'].toString();
    }
    if (json['startTime'] != null) {
      data.startTime = Duration(milliseconds: json['startTime']);
    }
    if (json['endTime'] != null) {
      data.endTime = Duration(milliseconds: json['endTime']);
    }
    if (json['isRemark'] != null) {
      data.isRemark = json['isRemark'];
    }
    return data;
  }

  Map<String, dynamic> toJson(Lyric entity) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lyric'] = entity.lyric;
    data['startTime'] = entity.startTime?.inMilliseconds ?? 0;
    data['endTime'] = entity.endTime?.inMilliseconds ?? 0;
    data['isRemark'] = entity.isRemark;
    return data;
  }
}

class FitterLyricUtil {
  static var tags = ['ti', 'ar', 'al', 'offset', 'by'];

  /// 格式化歌词
  static List<Lyric> formatLyric(String lyricStr) {
    if (lyricStr.trim().length == 0) {
      return [];
    }
    lyricStr = lyricStr.replaceAll("\r", "");
    RegExp reg = RegExp(r"""\[(.*?):(.*?)\](.*?)\n""");

    late Iterable<Match> matches;
    try {
      matches = reg.allMatches(lyricStr);
    } catch (e) {
      print(e.toString());
    }

    List<Lyric> lyrics = [];
    List<Match> list = matches.toList();
    for (int i = 0; i < list.length; i++) {
      var temp = list[i];
      var title = temp[1];
      if (!tags.contains(title) && list[i][3] != "") {
        lyrics.add(
          Lyric(
            lyric: list[i][3],
            startTime: lyricTimeToDuration(
              "${temp[1]}:${temp[2]}",
            ),
          ),
        );
      }
    }
    //移除所有空歌词
    lyrics.removeWhere((lyric) => lyric.lyric!.trim().isEmpty);
    for (int i = 0; i < lyrics.length - 1; i++) {
      lyrics[i].endTime = lyrics[i + 1].startTime;
    }
    lyrics.last.endTime = Duration(hours: 200);
    return lyrics;
  }

  static Duration lyricTimeToDuration(String time) {
    int minuteSeparatorIndex = time.indexOf(":");
    int secondSeparatorIndex = time.indexOf(".");

    // 分
    var minute = time.substring(0, minuteSeparatorIndex);
    // 秒
    var seconds =
        time.substring(minuteSeparatorIndex + 1, secondSeparatorIndex);
    // 微秒
    var millsceconds = time.substring(secondSeparatorIndex + 1);
    var microseconds = '0';
    // 判断是否存在微秒
    if (millsceconds.length > 3) {
      // 存在微秒 重新给予赋值
      microseconds = millsceconds.substring(3);
      millsceconds = millsceconds.substring(0, 3);
    }

    return Duration(
        minutes: int.parse(minute),
        seconds: int.parse(seconds),
        milliseconds: int.parse(millsceconds),
        microseconds: int.parse(microseconds));
  }
}
