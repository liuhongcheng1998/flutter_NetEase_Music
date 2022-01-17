// 这个是尝试使用scrollable_positioned_list生成歌词页

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mmoo_lyric/lyric.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MyLyricWidget extends StatefulWidget {
  /// 接受几个重要的参数 lyric - 歌词列表
  /// lyricStyle 全部歌词样式
  /// currLyricStyle 高亮歌词样式
  /// draggingLyricStyle 滑动选中歌词样式
  final List<Lyric> lyrics;
  final TextStyle? lyricStyle;
  final TextStyle? currLyricStyle;
  final TextStyle? draggingLyricStyle;
  Duration? progress;
  var callback;
  MyLyricWidget({
    Key? key,
    required this.lyrics,
    required this.progress,
    this.lyricStyle,
    this.currLyricStyle,
    this.draggingLyricStyle,
    required this.callback,
  }) : super(key: key);

  @override
  _MyLyricWidgetState createState() =>
      _MyLyricWidgetState(callback: this.callback);
}

class _MyLyricWidgetState extends State<MyLyricWidget> {
  late List<Lyric> lyrics;
  TextStyle? lyricStyle;
  TextStyle? currLyricStyle;
  TextStyle? draggingLyricStyle;
  Duration? progress;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int _currIndex = 0;
  int? selectIndex;
  GlobalKey _globalKey = GlobalKey();
  var containerHeight = 0.0;
  bool ismanual = false;
  var _timer;
  var callback;

  _MyLyricWidgetState({required this.callback});

  @override
  void initState() {
    super.initState();
    lyrics = widget.lyrics;
    lyricStyle = widget.lyricStyle;
    currLyricStyle = widget.currLyricStyle;
    draggingLyricStyle = widget.draggingLyricStyle;
    progress = widget.progress;
    _currIndex = findLyricIndexByDuration(progress!, lyrics);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      containerHeight = _globalKey.currentContext!.size!.height;
    });
    itemPositionsListener.itemPositions.addListener(() {
      List<ItemPosition> showList =
          itemPositionsListener.itemPositions.value.toList();
      showList.forEach((element) {
        if (element.itemLeadingEdge > 0.49 && element.itemLeadingEdge < 0.51) {
          if (ismanual) {
            this.setState(() {
              selectIndex = element.index;
            });
          }
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant MyLyricWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    var curLine = findLyricIndexByDuration(widget.progress!, widget.lyrics);
    if (_currIndex != curLine && !ismanual) {
      scrollTo(curLine);
      setState(() {
        progress = widget.progress;
      });
    }
    if (curLine == 0) {
      setState(() {
        progress = widget.progress;
      });
      jumpTo(0, 0);
    }
    this.setState(() {
      callback = widget.callback;
      lyrics = widget.lyrics;
    });
  }

  int findLyricIndexByDuration(Duration curDuration, List<Lyric> lyrics) {
    for (int i = 0; i < lyrics.length; i++) {
      if (curDuration >= lyrics[i].startTime! &&
          curDuration <= lyrics[i].endTime!) {
        return i;
      }
    }
    return 0;
  }

  jumpTo(int index, double align) async {
    itemScrollController.jumpTo(index: index, alignment: align);
  }

  scrollTo(int index) async {
    if (index == _currIndex) {
      return;
    }
    if (itemScrollController.isAttached) {
      await itemScrollController.scrollTo(
          index: index,
          duration: new Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          alignment: 0.5);
    }
    this.setState(() {
      _currIndex = index;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _globalKey,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onPanDown: (e) {
            _timer?.cancel();
            _timer = null;
            this.setState(() {
              ismanual = true;
            });
            int secound = 3;
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (secound == 0) {
                _timer?.cancel();
                this.setState(() {
                  ismanual = false;
                  selectIndex = null;
                });
                return;
              }
              secound--;
            });
          },
          child: ScrollablePositionedList.builder(
            itemCount: lyrics.length,
            padding: EdgeInsets.only(
                top: containerHeight / 2, bottom: containerHeight / 2),
            itemBuilder: (context, index) {
              if (progress!.inMilliseconds >=
                      lyrics[index].startTime!.inMilliseconds &&
                  progress!.inMilliseconds <=
                      lyrics[index].endTime!.inMilliseconds) {
                return Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      '${lyrics[index].lyric}',
                      style: currLyricStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (selectIndex != null) {
                if (selectIndex! == index) {
                  return Container(
                    alignment: Alignment.center,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        '${lyrics[index].lyric}',
                        style: draggingLyricStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              }
              return Container(
                alignment: Alignment.center,
                height: 40,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    '${lyrics[index].lyric}',
                    style: lyricStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
          ),
        ),
        Transform(
          transform: Matrix4.translationValues(0, 20, 0),
          child: Offstage(
            offstage: !ismanual,
            child: GestureDetector(
              onTap: () {
                Duration? secound = lyrics[selectIndex!].startTime;
                callback(secound);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white54,
                  ),
                  Expanded(
                    child: Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.white54,
                    ),
                    flex: 1,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
