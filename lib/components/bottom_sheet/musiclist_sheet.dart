// 底部弹窗

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/page_manager.dart';
import 'package:netease_app/services/service_locator.dart';

class MusicListWidget extends StatefulWidget {
  MusicListWidget({Key? key}) : super(key: key);

  @override
  _MusicListWidgetState createState() => _MusicListWidgetState();
}

class _MusicListWidgetState extends State<MusicListWidget> {
  _createListItem(
      MediaItem playitem, MediaItem item, PageManager model, int playindex) {
    bool ispaly = false;
    if (item.id == playitem.id) {
      ispaly = true;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 下标跳转
        model.playInex(playindex);
      },
      child: Container(
        width: double.infinity,
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  ispaly
                      ? Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 5),
                          child: LoadingIndicator(
                            indicatorType: Indicator.lineScaleParty,
                            colors: const [Colors.red],
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.title,
                            style: TextStyle(
                              color: ispaly ? Colors.red : Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: ' - ${item.artist}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ispaly ? Colors.red : Colors.black38,
                            ),
                          )
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    flex: 1,
                  )
                ],
              ),
              flex: 1,
            ),
            GestureDetector(
              child: Icon(
                Icons.close,
                color: Colors.black38,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = getIt<PageManager>();
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ValueListenableBuilder<List>(
          valueListenable: model.playlistNotifier,
          builder: (context, allplaylist, child) {
            return ValueListenableBuilder<MediaItem>(
              valueListenable: model.currentSongTitleNotifier,
              builder: (context, playitem, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '当前播放',
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
                            text: '(${allplaylist.length})',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  color: Colors.black38,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '列表循环',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: Icon(
                                  Icons.library_add,
                                  color: Colors.black38,
                                  size: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.black38,
                                  size: 18,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return _createListItem(
                              playitem, allplaylist[index], model, index);
                        },
                        itemCount: allplaylist.length,
                      ),
                      flex: 1,
                    ),
                  ],
                );
              },
            );
          },
        ));
  }
}
