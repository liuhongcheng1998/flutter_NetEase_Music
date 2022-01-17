// 路由配置文件

import 'package:flutter/material.dart';
import 'package:netease_app/components/live/live_video_player.dart';
import 'package:netease_app/pages/advertising.dart';
import 'package:netease_app/pages/index/all_live.dart';
import 'package:netease_app/pages/live/live_screen.dart';
import 'package:netease_app/pages/login/login.dart';
import 'package:netease_app/pages/navigation_button.dart';
import 'package:netease_app/pages/playlist/playlist.dart';
import 'package:netease_app/pages/playsongs/playsongs.dart';
import 'package:netease_app/pages/recommendSingle/recommend_single.dart';
import 'package:netease_app/pages/search/search.dart';
import 'package:netease_app/pages/search/search_result.dart';
import 'package:netease_app/pages/songComment/song_comment_page.dart';
import 'package:netease_app/pages/video_page/videoPage.dart';

final routes = {
  "/": (context) => NavigationButtonPage(),
  "/start": (context) => AdvertisingPage(),
  "/playlist": (context, {arguments}) => PlayListPage(
        playlistId: arguments,
      ),
  "/playsongs": (context) => PlaySongsPage(),
  "/search": (context, {arguments}) => SearchPage(
        searchTip: arguments["searchTip"],
        searchTips: arguments["searchTips"],
      ),
  "/searchresult": (context, {arguments}) => SearchResultPage(
        searchValue: arguments,
      ),
  "/login": (context) => UserLoginPage(),
  "/songcomment": (context, {arguments}) => SongCommentPage(
        songInfo: arguments,
      ),
  '/recommentsingle': (context) => RecommendSingle(),
  '/videoplaylist': (context, {arguments}) => VideoPlayListPage(
        videoId: arguments["id"],
        type: arguments["type"] ?? 0,
      ),
  '/livepage': (context, {arguments}) => LiveAllPage(
        tagid: arguments["tagid"],
        typetitle: arguments["typetitle"],
      ),
  '/liveroom': (context, {arguments}) => LiveVideoPlayerPage(
        url: arguments["url"],
        title: arguments["title"],
        liveType: arguments["liveType"],
        cover: arguments["cover"],
      ),
  '/livescreen': (context) => LiveScreenTypePgae(),
};

//固定写法
// ignore: top_level_function_literal_block
var onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String? name = settings.name;
  final Function? pageContentBuilder = routes[name];

  if (pageContentBuilder != null) {
    // 如果此路由返回的存在与路由中
    if (settings.arguments != null) {
      // 如果此路由携带了参数，将参数arguments 传过去
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      // 反之不携带参数
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  } else {
    // 这里处理找不到路由去到404页面
  }
};
