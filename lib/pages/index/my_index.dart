// 我的

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/components/audio_play/buttonAudioPlay.dart';
import 'package:netease_app/components/user/userPlaylist.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:netease_app/style/textstyle.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class MyIndexPage extends StatefulWidget {
  MyIndexPage({Key? key}) : super(key: key);

  @override
  _MyIndexPageState createState() => _MyIndexPageState();
}

class _MyIndexPageState extends State<MyIndexPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController; // 这个是tab栏操作
  ScrollController scrollController = ScrollController(); // listview 滚动
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  var oneY = 0.0; // 第一个元素距离顶部的高度
  var oneHeight = 0.0; // 第一个元素的高度
  var twoY = 0.0; // 第二个元素距离顶部的高度
  bool _istab = false; // 是否是tab切换
  var timer; // 延时器

  double getY(BuildContext buildContext, {isheigt = false}) {
    final RenderBox box = buildContext.findRenderObject() as RenderBox;
    final size = box.size;
    final topLeftPosition = box.localToGlobal(Offset.zero);
    final appbarheight = getAppbar(globalKeyThree.currentContext!);
    if (isheigt) {
      return size.height;
    } else {
      return topLeftPosition.dy - appbarheight - 40;
    }
  }

  double getAppbar(BuildContext buildContext) {
    final RenderBox box = buildContext.findRenderObject() as RenderBox;
    final size = box.size;
    return size.height;
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback(_afterLayout);
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  scrollHeight(of) {
    if (_istab == false) {
      if (of > oneY + oneHeight) {
        _tabController!.animateTo(1);
      } else {
        _tabController!.animateTo(0);
      }
    }
  }

  _afterLayout(_) {
    setState(() {
      oneY = getY(globalKeyOne.currentContext!);
      oneHeight = getY(globalKeyOne.currentContext!, isheigt: true);
      twoY = getY(globalKeyTwo.currentContext!);
    });
  }

  createUserLogo(bool islogin, userinfo) {
    if (islogin && userinfo != null) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                margin: EdgeInsets.only(right: 5, left: 10),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 240, 242, 1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(width: 1, color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 1,
                      color: Colors.black12,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.network(
                    '${userinfo["avatarUrl"]}?param=100y100',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${userinfo["nickname"]}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Container(
                margin: EdgeInsets.only(right: 5, left: 10),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(244, 240, 242, 1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(width: 1, color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 1,
                      color: Colors.black12,
                    )
                  ],
                ),
                child: Icon(
                  Icons.person,
                  color: Color.fromRGBO(244, 216, 213, 1),
                  size: 50,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '立即登录',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                  ),
                ],
              ),
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
          )
        ],
      );
    }
  }

  double opacity = 1;

  setOpacity(offset) {
    if (offset <= 0) {
      double alpha = offset.abs() / 100;
      if (alpha < 0) {
        alpha = 0;
      } else if (alpha >= 1) {
        alpha = 1;
      }
      setState(() {
        opacity = 1 - alpha;
      });
    }
  }

  createItemButton(String url, String text) {
    return Container(
      width: 60,
      child: Column(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Color.fromRGBO(212, 59, 45, 0.78),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset(url),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  getCreateplaylist(bool islogin, List playList) {
    // 获取创建歌单
    if (islogin) {
      return Container(
        key: globalKeyOne,
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(5),
        decoration: defaultContainerborderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '创建歌单',
                    style: tipsTitleStyle,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.more_vert),
                )
              ],
            ),
            UserPlayListWidget(
              iscreate: true,
              playList: playList,
            ),
          ],
        ),
      );
    } else {
      return Container(
        key: globalKeyOne,
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(5),
        decoration: defaultContainerborderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '创建歌单',
                    style: tipsTitleStyle,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.more_vert),
                )
              ],
            ),
            Container(
              width: double.infinity,
              height: 100,
              child: Center(
                child: Text(
                  '登录后可查看!',
                  style: tipsTitleStyle,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  getCollectplaylist(bool islogin, List playList) {
    // 获取收藏歌单
    if (islogin) {
      return Container(
        key: globalKeyTwo,
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(5),
        decoration: defaultContainerborderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '收藏歌单',
                    style: tipsTitleStyle,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.more_vert),
                )
              ],
            ),
            UserPlayListWidget(
              iscreate: false,
              playList: playList,
            ),
          ],
        ),
      );
    } else {
      return Container(
        key: globalKeyTwo,
        width: double.infinity,
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(5),
        decoration: defaultContainerborderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '收藏歌单',
                    style: tipsTitleStyle,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.more_vert),
                )
              ],
            ),
            Container(
              width: double.infinity,
              height: 100,
              child: Center(
                child: Text(
                  '登录后可查看!',
                  style: tipsTitleStyle,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  // 我喜欢的音乐
  createfav(favitem) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(left: 15, right: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            color: Colors.black12,
          )
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          print('favitem${favitem["id"]}');
          Navigator.of(context).pushNamed(
            '/playlist',
            arguments: favitem["id"],
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // 图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(164, 164, 164, 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: favitem != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              '${favitem["coverImgUrl"]}?param=100y100',
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('我喜欢的音乐'),
                      Text(
                        '${favitem != null ? favitem["trackCount"] : 0}首',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              flex: 1,
            ),
            // 右侧心动模式button
            Container(
              height: 28,
              child: OutlinedButton(
                  onPressed: () => {},
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    )),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      StadiumBorder(
                        side: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 18,
                        color: Colors.black38,
                      ),
                      Text(
                        '心动模式',
                        style: TextStyle(
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(248, 248, 248, 1),
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: new BoxDecoration(
              color: Colors.grey,
              borderRadius: new BorderRadius.only(
                bottomLeft: Radius.elliptical(200, 10),
                bottomRight: Radius.elliptical(200, 10),
              ),
              image: new DecorationImage(
                image: AssetImage('images/default/bg_daily.png'),
                centerSlice: new Rect.fromLTRB(70.0, 180.0, 1360.0, 730.0),
              ),
            ),
          ),
          Opacity(
            opacity: opacity,
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: new BoxDecoration(
                color: Color.fromRGBO(248, 248, 248, 1),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              key: globalKeyThree,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              elevation: 0,
              centerTitle: true,
              leading: Icon(
                Icons.format_align_left,
                color: Colors.black,
              ),
              actions: [
                Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            body: Stack(
              children: [
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: NotificationListener(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification &&
                          scrollNotification.depth == 0) {
                        if (oneHeight !=
                            getY(globalKeyOne.currentContext!, isheigt: true)) {
                          setState(() {
                            oneHeight = getY(globalKeyOne.currentContext!,
                                isheigt: true);
                          });
                        }
                        setOpacity(scrollNotification.metrics.pixels);
                        scrollHeight(scrollNotification.metrics.pixels);
                      }
                      return true;
                    },
                    child: Consumer<DefaultProvider>(
                      builder: (context, user, child) {
                        return Container(
                          // padding: EdgeInsets.only(left: 15, right: 15),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(left: 15, right: 15),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      color: Colors.black12,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    createUserLogo(user.islogin, user.userInfo),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.only(left: 15, right: 15),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      color: Colors.black12,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "最近播放"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "本地/下载"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "云盘"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "已购"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "我的好友"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "收藏和赞"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "我的播客"),
                                        createItemButton(
                                            "images/default/icon_radio.png",
                                            "音乐罐子"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // ============我喜欢的音乐
                              createfav(user.userFavorite),
                              SizedBox(
                                height: 20,
                              ),
                              // ===========吸顶===============
                              StickyHeaderBuilder(
                                builder: (context, double stuckAmount) {
                                  stuckAmount =
                                      1.0 - stuckAmount.clamp(0.0, 1.0);
                                  return Container(
                                    height: 40,
                                    width: double.infinity,
                                    color: Color.lerp(
                                        Color.fromRGBO(255, 255, 255, 0),
                                        Color.fromRGBO(248, 248, 248, 1),
                                        stuckAmount),
                                    // color: Colors.white,
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0),
                                    margin: EdgeInsets.only(bottom: 20),
                                    alignment: Alignment.center,
                                    child: TabBar(
                                      isScrollable: true,
                                      tabs: [
                                        Text('创建歌单'),
                                        Text('收藏歌单'),
                                      ],
                                      controller: _tabController,
                                      indicatorColor: Colors.black,
                                      indicatorWeight: 3,
                                      unselectedLabelColor: Colors.grey,
                                      labelColor: Color.fromRGBO(0, 0, 0, 0.87),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      onTap: (index) {
                                        if (_tabController!.indexIsChanging) {
                                          timer?.cancel();
                                          _istab = true;
                                          switch (index) {
                                            case 0:
                                              scrollController.animateTo(oneY,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                              _tabController!.animateTo(0);

                                              break;
                                            case 1:
                                              scrollController.animateTo(
                                                  oneY + oneHeight,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.ease);
                                              _tabController!.animateTo(1);

                                              break;
                                          }
                                          timer = Timer(
                                              Duration(milliseconds: 500), () {
                                            _istab = false;
                                          });
                                        }
                                      },
                                    ),
                                  );
                                },
                                content: Column(
                                  children: [
                                    // 创建歌单
                                    getCreateplaylist(
                                        user.islogin, user.userPlayList),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    // 收藏歌单
                                    getCollectplaylist(
                                        user.islogin, user.subscribedList),
                                    SizedBox(
                                      height: 60,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonPlayWight(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
