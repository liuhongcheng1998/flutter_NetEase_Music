import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/components/bottom_sheet/musiclist_sheet.dart';
import 'package:netease_app/http/request.dart';
import 'package:netease_app/model/widget_img_menu.dart';
import 'package:netease_app/notifiers/play_button_notifier.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:netease_app/utils/number_utils.dart';
import 'package:netease_app/wight/widget_future_builder.dart';
import 'package:provider/provider.dart';

class PlayBottomMenuWidget extends StatelessWidget {
  final PageManager model;

  PlayBottomMenuWidget(this.model);

  _showBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false, // 全屏还是半屏
        isDismissible: true, // 是否可以点击外部执行关闭
        context: context,
        enableDrag: true, // 是否允许手动关闭
        builder: (BuildContext context) {
          return MusicListWidget();
        });
  }

  getComments(context, params) async {
    var data = await getSongsComment(params);
    if (data["code"] == 200) {
      return data["data"];
    } else {
      return null;
    }
  }

  changeislike(bool islike, String id, DefaultProvider user) async {
    Map<String, dynamic> params = {
      "id": '$id',
      "like": islike,
    };
    changLikeSong(params).then((value) {
      if (value["code"] == 200) {
        if (islike) {
          // 这里是添加
          EasyLoading.showToast(
            '已添加到喜欢',
            toastPosition: EasyLoadingToastPosition.center,
            duration: Duration(seconds: 2),
          );
          user.changefavsong(true, id);
        } else {
          // 这里是移除
          EasyLoading.showToast(
            '已取消喜欢',
            toastPosition: EasyLoadingToastPosition.center,
            duration: Duration(seconds: 2),
          );
          user.changefavsong(false, id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DefaultProvider>(
      builder: (context, user, child) {
        return Container(
          height: 80,
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<ButtonState>(
            valueListenable: model.playButtonNotifier,
            builder: (context, value, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: model.isPersonFm,
                builder: (context, isPersonFm, child) {
                  String id = model.currentSongTitleNotifier.value.id;
                  List userFav = user.userfavoriteSong;
                  bool isfav = false;
                  if (userFav.isNotEmpty) {
                    isfav = userFav.any((element) => '$element' == id);
                  }
                  return Row(
                    children: <Widget>[
                      isPersonFm
                          ? ImageMenuWidget(
                              isfav
                                  ? 'images/default/icon_liked.png'
                                  : 'images/default/icon_dislike.png',
                              40,
                              onTap: () {
                                changeislike(!isfav, id, user);
                              },
                            )
                          : ImageMenuWidget(
                              'images/default/icon_song_play_type_1.png',
                              40,
                              onTap: () {},
                            ),
                      isPersonFm
                          ? ImageMenuWidget(
                              'images/default/icon_dislike_type1.png', 40,
                              onTap: () {})
                          : ImageMenuWidget(
                              'images/default/icon_song_left.png',
                              40,
                              onTap: () {
                                model.previous();
                              },
                            ),
                      //icon_song_play_loading
                      value == ButtonState.loading
                          ? ImageMenuWidget(
                              'images/default/icon_song_play_loading.png',
                              60,
                              onTap: () {
                                // model.togglePlay();
                              },
                            )
                          : ImageMenuWidget(
                              value != ButtonState.paused
                                  ? 'images/default/icon_song_pause.png'
                                  : 'images/default/icon_song_play.png',
                              60,
                              onTap: () {
                                model.togglePlay();
                              },
                            ),
                      ImageMenuWidget(
                        'images/default/icon_song_right.png',
                        40,
                        onTap: () {
                          model.next();
                        },
                      ),
                      isPersonFm
                          ? CustomFutureBuilder(
                              futureFunc: getComments,
                              params: {
                                "id":
                                    '${model.currentSongTitleNotifier.value.id}',
                                'type': "0"
                              },
                              loadingWidget: ImageMenuWidget(
                                'images/default/icon_song_comment.png',
                                40,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/songcomment',
                                    arguments:
                                        model.currentSongTitleNotifier.value,
                                  );
                                },
                              ),
                              builder: (context, data) {
                                data as Map;
                                return Expanded(
                                  child: Container(
                                    // width: 80,
                                    height: 40,
                                    // margin: EdgeInsets.only(right: 5),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          '/songcomment',
                                          arguments: model
                                              .currentSongTitleNotifier.value,
                                        );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'images/default/icon_song_comment.png',
                                            width: 40,
                                            height: 40,
                                          ),
                                          Positioned(
                                            left: 42,
                                            bottom: 21,
                                            child: Container(
                                              width: 80,
                                              child: Text(
                                                '${NumberUtils.formatNum(data["totalCount"])}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : ImageMenuWidget(
                              'images/default/icon_play_songs.png',
                              40,
                              onTap: () {
                                _showBottomSheet(context);
                              },
                            ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
