// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/preferences/user_preferences.dart';

class DefaultProvider with ChangeNotifier {
  var _userInfo; // 登录后用户信息
  int? _userId; // 用户id
  bool _islogin = false; // 是否处于登录状态
  List _userPlayList = []; // 用户创建的音乐
  List _userFavorite = []; // 用户喜欢的音乐
  List _subscribedList = []; // 用户收藏的音乐
  List _favsongList = []; // 用户喜欢的音乐id

  void init() async {
    var cookies = await getCookies();
    if (cookies != null) {
      print('登录状态');
      _islogin = true;
      // 登录了拉取用户信息
      await getAccountInfo();
    } else {
      print('未登录');
      _islogin = false;
    }
  }

  getUPlayList() async {
    var data = await getUserPlayList({"limit": "100", "uid": "$userId"});
    if (data["code"] == 200) {
      List playlist = data["playlist"];
      _userPlayList = playlist
          .where((element) =>
              element["userId"] == userId && element["specialType"] != 5)
          .toList();
      _subscribedList =
          playlist.where((element) => element["userId"] != userId).toList();
      _userFavorite = playlist
          .where((element) =>
              element["userId"] == userId && element["specialType"] == 5)
          .toList();
    } else {
      _userPlayList = [];
      _subscribedList = [];
      _userFavorite = [];
    }
    if (_userFavorite.isNotEmpty) {
      getfavsongs();
    }
    notifyListeners();
  }

  updatePlayList() async {
    await getUPlayList();
  }

  changefavsong(bool isadd, String id) {
    bool ishave = _favsongList.any((element) => '$element' == id);
    if (isadd) {
      if (!ishave) {
        _favsongList.add('$id');
      }
    } else {
      if (ishave) {
        _favsongList.remove('$id');
      }
    }
    notifyListeners();
  }

  getfavsongs() async {
    var params = {"id": "${_userFavorite[0]['id']}"};
    getPlaylistDetail(params).then((value) {
      if (value["code"] == 200) {
        List list = value["playlist"]["trackIds"];
        _favsongList = list.map((element) {
          return '${element["id"]}';
        }).toList();
      }
    });
    notifyListeners();
  }

  getAccountInfo() async {
    var data = await getLoginAccountInfo();
    if (data["code"] == 200) {
      await setUserInfo(data["profile"]);
      await setUserId(data["profile"]["userId"]);
      getUPlayList();
    }
  }

  Future loginByPhone(loginform) async {
    var data = await userLoginByPhone(loginform);
    print('登录接口$data');
    if (data["code"] == 200) {
      // 登录成功
      // 这里获取用户信息
      await setCookeis(data["cookie"]);
      setUserInfo(data["profile"]);
      setIsLogin(true);
      setUserId(data["profile"]["userId"]);
      return data;
    } else {
      // 登录失败
      return data;
    }
  }

  setUserInfo(userinfo) {
    _userInfo = userinfo;
    notifyListeners();
  }

  setUserId(int? id) {
    _userId = id;
    notifyListeners();
  }

  setIsLogin(bool login) {
    _islogin = login;
    notifyListeners();
  }

  bool get islogin => _islogin;

  get userId => _userId;

  get userInfo => _userInfo;

  List get userPlayList => _userPlayList;
  List get subscribedList => _subscribedList;
  List get userfavoriteSong => _favsongList;
  get userFavorite => _userFavorite.isNotEmpty ? _userFavorite[0] : null;
}
