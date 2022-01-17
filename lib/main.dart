import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:netease_app/routers/router.dart';
import 'package:netease_app/services/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'page_manager.dart';

void main() async {
  await setupServiceLocator();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DefaultProvider()..init()),
      ],
      child: MyApp(),
    ));
  });

  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
    Provider.of<DefaultProvider>(context, listen: false);
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      // 嵌套用于改变语言
      builder: (context, currentLocale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // 取消头部bug
          initialRoute: '/start', //初始化的时候加载的路由
          onGenerateRoute: onGenerateRoute,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            platform: TargetPlatform.iOS,
          ),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.

  
//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }
