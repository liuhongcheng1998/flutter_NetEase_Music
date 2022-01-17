// 用户缓存

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// 存cookies
Future setCookeis(String cookies) async {
  final com = Completer();

  final future = com.future;

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cookies', cookies);
    com.complete(true);
  } catch (e) {
    com.complete(false);
  }

  return future;
}

// 取cookies
Future getCookies() async {
  final com = Completer();
  final future = com.future;

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final values = prefs.getString('cookies') ?? null;
    com.complete(values);
  } catch (err) {
    com.complete(null);
  }

  return future;
}

// 移除
void removeToken() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cookies');
  } catch (err) {
    print(err.toString());
  }
}
