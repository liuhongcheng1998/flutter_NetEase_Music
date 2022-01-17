// 歌单的头部

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/wight/backbroundAppBar.dart';
import 'package:netease_app/wight/playPaint.dart';

// ignore: must_be_immutable
class PlaylistAppBar extends StatefulWidget {
  String imageUrl;
  String appbarTitle;
  var playlistdetail;
  String collection;
  String chat;
  String share;
  int playCount;
  String avatorUrl;
  void Function()? playall;
  PlaylistAppBar(
      {Key? key,
      this.imageUrl = 'images/default/playlistdefault.png',
      this.appbarTitle = '歌单',
      this.playlistdetail,
      this.collection = '收藏',
      this.chat = '评论',
      this.share = '分享',
      this.playCount = 0,
      this.avatorUrl = '',
      this.playall})
      : super(key: key);

  @override
  _PlaylistAppBarState createState() => _PlaylistAppBarState(
        imageUrl: this.imageUrl,
        appbarTitle: this.appbarTitle,
        playlistdetail: this.playlistdetail,
        chat: this.chat,
        collection: this.collection,
        playCount: this.playCount,
        share: this.share,
        avatorUrl: this.avatorUrl,
        playall: this.playall,
      );
}

class _PlaylistAppBarState extends State<PlaylistAppBar> {
  String imageUrl;
  String appbarTitle;
  var playlistdetail;
  String collection;
  String chat;
  String share;
  int playCount;
  String avatorUrl;
  void Function()? playall;
  _PlaylistAppBarState({
    required this.imageUrl,
    this.appbarTitle = '歌单',
    this.playlistdetail,
    this.collection = '收藏',
    this.chat = '评论',
    this.share = '分享',
    this.playCount = 0,
    this.avatorUrl = '',
    this.playall,
  });

  var backimage;

  @override
  void initState() {
    super.initState();
    if (imageUrl.startsWith('http')) {
      backimage = NetworkImage(imageUrl);
    } else {
      backimage = ExactAssetImage(imageUrl);
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      imageUrl = widget.imageUrl;
      appbarTitle = widget.appbarTitle;
      chat = widget.chat;
      share = widget.share;
      collection = widget.collection;
      avatorUrl = widget.avatorUrl;
      playCount = widget.playCount;
      playlistdetail = widget.playlistdetail;
      playall = widget.playall;
    });
    if (imageUrl.startsWith('http')) {
      backimage = NetworkImage(imageUrl);
    } else {
      backimage = ExactAssetImage(imageUrl);
    }
  }

  createBarInfo() {
    if (playlistdetail == null) {
      return Container(
        height: 120,
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            Text(
              '暂无数据',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 120,
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${playlistdetail["name"]}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child:
                        Image.network(playlistdetail["creator"]["avatarUrl"]),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '${playlistdetail["creator"]["nickname"]}',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            Text(
              '${playlistdetail["description"]}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  filterNum(String num) {
    var newnum = int.tryParse(num);
    if (newnum != null) {
      if (newnum > 10000) {
        return (newnum / 10000).toStringAsFixed(1) + '万';
      } else {
        return newnum.toString();
      }
    } else {
      return num;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Color.fromRGBO(178, 178, 178, 1),
      centerTitle: true, // 不用过多解释
      pinned: true, // 设置为true时，当SliverAppBar内容滑出屏幕时，将始终渲染一个固定在顶部的收起状态
      elevation: 0, // 阴影
      // snap: true,
      // floating: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      stretch: true,
      iconTheme: IconThemeData(color: Colors.white),
      expandedHeight: 310.0,
      title: Text(
        appbarTitle,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      bottom: new PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          width: double.infinity,
          color: Colors.white,
          child: Row(
            children: [
              GestureDetector(
                onTap: playall,
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle,
                      color: Colors.red,
                      size: 34,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '播放全部',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          WidgetSpan(
                            child: SizedBox(
                              width: 10,
                            ),
                          ),
                          TextSpan(
                            text: '($playCount)',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      flexibleSpace: new BackgroundFlexibleSpaceBar(
        backimage: backimage,
        imageUrl: this.imageUrl,
        appbarTitle: this.appbarTitle,
        playlistdetail: this.playlistdetail,
        chat: this.chat,
        collection: this.collection,
        playCount: this.playCount,
        share: this.share,
        avatorUrl: this.avatorUrl,
        background: Container(),
        // background: Stack(
        //   children: [
        //     Container(
        //       width: double.maxFinite,
        //       decoration: BoxDecoration(
        //         image: DecorationImage(
        //           image: backimage, //背景图片
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //       child: ClipRRect(
        //         // make sure we apply clip it properly
        //         child: BackdropFilter(
        //           //背景滤镜
        //           filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), //背景模糊化
        //           child: Container(
        //             color: Colors.black38,
        //           ),
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //       bottom: 0,
        //       left: 0,
        //       right: 0,
        //       child: Container(
        //         height: 100,
        //         child: CustomPaint(
        //           painter: Sky(),
        //         ),
        //       ),
        //     ),
        //     Align(
        //       // width: double.infinity,
        //       alignment: Alignment.bottomCenter,
        //       child: Opacity(
        //         opacity: 1,
        //         child: Container(
        //           width: double.infinity,
        //           padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        //           margin: EdgeInsets.only(bottom: 60),
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.end,
        //             children: [
        //               Row(
        //                 crossAxisAlignment: CrossAxisAlignment.end,
        //                 children: [
        //                   Container(
        //                     height: 120,
        //                     width: 120,
        //                     decoration: BoxDecoration(
        //                       color: Colors.white,
        //                       borderRadius: BorderRadius.circular(10),
        //                     ),
        //                     child: avatorUrl.isNotEmpty
        //                         ? ClipRRect(
        //                             borderRadius: BorderRadius.circular(10),
        //                             child: Image.network(avatorUrl),
        //                           )
        //                         : Center(),
        //                   ),
        //                   Expanded(
        //                     child: createBarInfo(),
        //                     flex: 1,
        //                   ),
        //                 ],
        //               ),
        //               SizedBox(
        //                 height: 20,
        //               ),
        //               Container(
        //                 width: 300,
        //                 height: 40,
        //                 padding: EdgeInsets.only(
        //                   left: 10,
        //                   right: 10,
        //                 ),
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(30),
        //                   color: Colors.white,
        //                 ),
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                   children: [
        //                     TextButton.icon(
        //                       onPressed: null,
        //                       icon: Icon(
        //                         Icons.library_add,
        //                         size: 18,
        //                       ),
        //                       label: Text(
        //                         filterNum(collection),
        //                       ),
        //                       style: ButtonStyle(
        //                         overlayColor: MaterialStateProperty.all(
        //                           Colors.transparent,
        //                         ),
        //                         padding: MaterialStateProperty.all(
        //                             EdgeInsets.all(0)),
        //                         foregroundColor:
        //                             MaterialStateProperty.resolveWith((state) {
        //                           if (state.contains(MaterialState.disabled)) {
        //                             return Colors.black38;
        //                           } else {
        //                             return Colors.black87;
        //                           }
        //                         }),
        //                       ),
        //                     ),
        //                     VerticalDivider(),
        //                     TextButton.icon(
        //                       onPressed: null,
        //                       icon: Icon(
        //                         Icons.chat,
        //                         size: 18,
        //                       ),
        //                       label: Text(filterNum(chat)),
        //                       style: ButtonStyle(
        //                         overlayColor: MaterialStateProperty.all(
        //                           Colors.transparent,
        //                         ),
        //                         padding: MaterialStateProperty.all(
        //                             EdgeInsets.all(0)),
        //                         foregroundColor:
        //                             MaterialStateProperty.resolveWith((state) {
        //                           if (state.contains(MaterialState.disabled)) {
        //                             return Colors.black38;
        //                           } else {
        //                             return Colors.black87;
        //                           }
        //                         }),
        //                       ),
        //                     ),
        //                     VerticalDivider(),
        //                     TextButton.icon(
        //                       onPressed: null,
        //                       icon: Icon(
        //                         Icons.share,
        //                         size: 18,
        //                       ),
        //                       label: Text(filterNum(share)),
        //                       style: ButtonStyle(
        //                         overlayColor: MaterialStateProperty.all(
        //                           Colors.transparent,
        //                         ),
        //                         padding: MaterialStateProperty.all(
        //                             EdgeInsets.all(0)),
        //                         foregroundColor:
        //                             MaterialStateProperty.resolveWith((state) {
        //                           if (state.contains(MaterialState.disabled)) {
        //                             return Colors.black38;
        //                           } else {
        //                             return Colors.black87;
        //                           }
        //                         }),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               )
        //             ],
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
// Container(
//           // height: 230,
//           width: double.maxFinite,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: backimage, //背景图片
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: ClipRRect(
//             // make sure we apply clip it properly
//             child: BackdropFilter(
//                 //背景滤镜
//                 filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), //背景模糊化
//                 child: Stack(
//                   children: [
//                     Align(
//                       // width: double.infinity,
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                         margin: EdgeInsets.only(bottom: 60),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Container(
//                                   height: 120,
//                                   width: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: avatorUrl.isNotEmpty
//                                       ? ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           child: Image.network(avatorUrl),
//                                         )
//                                       : Center(),
//                                 ),
//                                 Expanded(
//                                   child: createBarInfo(),
//                                   flex: 1,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 20,
//                             ),
//                             Container(
//                               width: 300,
//                               height: 40,
//                               padding: EdgeInsets.only(
//                                 left: 10,
//                                 right: 10,
//                               ),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(30),
//                                 color: Colors.white,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   TextButton.icon(
//                                     onPressed: null,
//                                     icon: Icon(
//                                       Icons.library_add,
//                                       size: 18,
//                                     ),
//                                     label: Text(
//                                       filterNum(collection),
//                                     ),
//                                     style: ButtonStyle(
//                                       overlayColor: MaterialStateProperty.all(
//                                         Colors.transparent,
//                                       ),
//                                       padding: MaterialStateProperty.all(
//                                           EdgeInsets.all(0)),
//                                       foregroundColor:
//                                           MaterialStateProperty.resolveWith(
//                                               (state) {
//                                         if (state
//                                             .contains(MaterialState.disabled)) {
//                                           return Colors.black38;
//                                         } else {
//                                           return Colors.black87;
//                                         }
//                                       }),
//                                     ),
//                                   ),
//                                   VerticalDivider(),
//                                   TextButton.icon(
//                                     onPressed: null,
//                                     icon: Icon(
//                                       Icons.chat,
//                                       size: 18,
//                                     ),
//                                     label: Text(filterNum(chat)),
//                                     style: ButtonStyle(
//                                       overlayColor: MaterialStateProperty.all(
//                                         Colors.transparent,
//                                       ),
//                                       padding: MaterialStateProperty.all(
//                                           EdgeInsets.all(0)),
//                                       foregroundColor:
//                                           MaterialStateProperty.resolveWith(
//                                               (state) {
//                                         if (state
//                                             .contains(MaterialState.disabled)) {
//                                           return Colors.black38;
//                                         } else {
//                                           return Colors.black87;
//                                         }
//                                       }),
//                                     ),
//                                   ),
//                                   VerticalDivider(),
//                                   TextButton.icon(
//                                     onPressed: null,
//                                     icon: Icon(
//                                       Icons.share,
//                                       size: 18,
//                                     ),
//                                     label: Text(filterNum(share)),
//                                     style: ButtonStyle(
//                                       overlayColor: MaterialStateProperty.all(
//                                         Colors.transparent,
//                                       ),
//                                       padding: MaterialStateProperty.all(
//                                           EdgeInsets.all(0)),
//                                       foregroundColor:
//                                           MaterialStateProperty.resolveWith(
//                                               (state) {
//                                         if (state
//                                             .contains(MaterialState.disabled)) {
//                                           return Colors.black38;
//                                         } else {
//                                           return Colors.black87;
//                                         }
//                                       }),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 )),
//           ),
//         ),