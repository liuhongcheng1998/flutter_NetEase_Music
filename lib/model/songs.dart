// 构造class 歌曲

class Song {
  int id; // 歌曲id
  String name; // 歌曲名字
  String artists; // 艺术家
  String picUrl; // 歌曲图片
  Duration timer;
  Song(this.id, this.timer,
      {this.name = '', this.artists = '', this.picUrl = ''});
  Song.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['name'],
        artists = json['artists'],
        timer = Duration(milliseconds: int.parse(json["timer"])),
        picUrl = json['picUrl'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'artists': artists,
        'picUrl': picUrl,
        'timer': timer,
      };

  @override
  String toString() {
    return '{"id": "$id", "name": "$name", "artists": "$artists","picUrl": "$picUrl","timer": "${timer.inMilliseconds}"}';
  }
}
