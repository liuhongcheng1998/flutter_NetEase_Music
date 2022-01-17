// 这里是请求的所有处理

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:netease_app/preferences/user_preferences.dart';

dioget(api, params) async {
  var cookies = await getCookies() ?? '';
  BaseOptions options = BaseOptions();
  options.baseUrl = "http://wwww.tq0914.ltd:8090/";
  Dio dio = Dio(options);
  if (cookies != null) {
    params["cookie"] = cookies;
  }
  try {
    var data = await dio.get(api, queryParameters: params);
    var _data = jsonDecode(data.toString());
    return _data;
  } catch (e) {
    return {"code": 500, "msg": "error$e"};
  }
}

Future https(String api, Map<String, dynamic> obj) async {
  try {
    Dio dio = Dio();
    dio.options.baseUrl = "http://www.tq0914.ltd:8090";
    dio.options.connectTimeout = 120000; //链接超时，单位为毫秒
    dio.options.receiveTimeout = 3000; //接收超时，单位毫秒
    print(api);

    var cookies = await getCookies() ?? '';
    if (cookies != null) {
      obj["cookie"] = cookies;
    }

    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    //     // 这里是dio前置
    //   },
    //   onResponse:
    //       (Response<dynamic> response, ResponseInterceptorHandler handler) {
    //     // 后置
    //   },
    //   onError: (e, ErrorInterceptorHandler error) {
    //     // 报错
    //   },
    // ));

    var response = await dio.get(api, queryParameters: obj);
    var _data = jsonDecode(response.toString());
    return _data;
  } catch (e) {
    return e;
  }
}

Future liveshttps(String api, String baseUrl, Map<String, dynamic> obj) async {
  print(api);
  print(baseUrl);
  try {
    Dio dio = Dio();
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 120000; //链接超时，单位为毫秒
    dio.options.receiveTimeout = 3000; //接收超时，单位毫秒

    var response = await dio.get(api, queryParameters: obj);
    var _data = jsonDecode(response.toString());
    return _data;
  } catch (e) {
    return e;
  }
}

// 获取banner
Future getBanner(params) async {
  try {
    var data = https('/banner', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取推荐歌单
Future getPersonalized(params) async {
  try {
    var data = https('/personalized', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 热搜简略
Future getHotSearchList() async {
  try {
    var data = https('/search/hot', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 热搜详情
Future getHotSearchDetail() async {
  try {
    var data = https('/search/hot/detail', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 搜索建议

Future getSearchTipsList(params) async {
  try {
    var data = await https('/search/suggest', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 搜索
Future searchValueResult(params) async {
  try {
    var data = await https('/search', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 详细搜索
Future searchValueResultDet(params) async {
  try {
    var data = await https('/cloudsearch', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 首页发现所以信息
Future getFindMusicAll(params) async {
  try {
    var data = https('/homepage/block/page', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取歌曲url
Future getSongUrl(params) async {
  try {
    var data = await https("/song/url", params);
    return data["data"][0]["url"];
  } catch (e) {
    return "";
  }
}

// 获取歌单详情
Future getPlaylistDetail(params) async {
  try {
    var data = await https('/playlist/detail', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取歌单所以音乐

Future getPlaylistSongs(params) async {
  try {
    var data = await https('/song/detail', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取歌词

Future getsongsLyricData(params) async {
  try {
    var data = await https('/lyric', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取账号信息
Future getLoginAccountInfo() async {
  try {
    var data = await https('/user/account', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 获取用户信息

Future getLoginUserInfo() async {
  try {
    var data = await https('/user/subcount', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 手机号密码登录

Future userLoginByPhone(params) async {
  try {
    var data = await https('/login/cellphone', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 用户歌单

Future getUserPlayList(params) async {
  try {
    var data = await https('/user/playlist', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 歌曲评论
Future getSongsComment(params) async {
  try {
    var data = await https('/comment/new', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 私人FM

Future getPersonaFm(params) async {
  try {
    var data = await https('/personal_fm', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 首页发现图标

Future getFindMusicIcon() async {
  try {
    var data = await https('/homepage/dragon/ball', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 修改喜欢音乐

Future changLikeSong(params) async {
  try {
    var data = await https('/like', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取每日推荐歌曲

Future getRecommendSingle() async {
  try {
    var data = await https('/recommend/songs', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 获取mv详情

Future getMvdetail(params) async {
  try {
    var data = await https('/mv/detail', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取相似mv
Future getSimiMv(params) async {
  try {
    var data = await https('/simi/mv', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取播放地址

Future getMvUrl(params) async {
  try {
    var data = await https('/mv/url', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取视频详情

Future getVideoDetail(params) async {
  try {
    var data = await https('/video/detail', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取相似视频

Future getSimiVideo(params) async {
  try {
    var data = await https('/related/allvideo', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 获取视频播放地址

Future getVideoUrl(params) async {
  try {
    var data = await https('/video/url', params);
    return data;
  } catch (e) {
    return e;
  }
}

// ==================直播模块==============

Future getLiveTypeList() async {
  try {
    var data =
        await liveshttps('/xcdsw/json.txt', 'http://api.vipmisss.com:81', {});
    return data;
  } catch (e) {
    return e;
  }
}

Future getLiveItemList(String url) async {
  try {
    var data = await liveshttps('/mf/$url', 'http://api.vipmisss.com:81', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 斗鱼直播api===========

// 斗鱼全部直播
Future getdouyuAllList(params, {String id = ''}) async {
  try {
    var data;
    if (id.isNotEmpty) {
      data = await liveshttps(
          '/api/v1/live/$id', 'http://capi.douyucdn.cn', params);
    } else {
      data =
          await liveshttps('/api/v1/live', 'http://capi.douyucdn.cn', params);
    }
    return data;
  } catch (e) {
    return e;
  }
}

// 斗鱼大分类

Future getdouyuBigType() async {
  try {
    var data = await liveshttps(
        '/api/v1/getColumnList', 'http://capi.douyucdn.cn', {});
    return data;
  } catch (e) {
    return e;
  }
}

// 斗鱼子分类

Future getdouyuSmallType(params) async {
  try {
    var data = await liveshttps(
        '/api/v1/getColumnDetail', 'http://capi.douyucdn.cn', params);
    return data;
  } catch (e) {
    return e;
  }
}

// 斗鱼房间号

Future getLiveRoom(params) async {
  try {
    var data =
        await liveshttps('/lxapi/douyujx.x', 'https://web.sinsyth.com', params);
    return data;
  } catch (e) {
    return e;
  }
}
