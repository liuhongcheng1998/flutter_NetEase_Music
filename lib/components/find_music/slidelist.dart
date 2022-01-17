// 推荐歌单

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
// import 'package:netease_app/http/request.dart';

// ignore: must_be_immutable
class SlideListPage extends StatefulWidget {
  List recommendList;
  String title;
  SlideListPage({Key? key, required this.recommendList, required this.title})
      : super(key: key);

  @override
  _SlideListPageState createState() =>
      _SlideListPageState(recommendList: this.recommendList, title: this.title);
}

class _SlideListPageState extends State<SlideListPage> {
  List recommendList;
  String title;
  _SlideListPageState({required this.recommendList, required this.title});
  @override
  void initState() {
    super.initState();
    print('silder$recommendList');
    print('silder$title');
  }

  String compCount(value) {
    if (value is int) {
      if (value > 10000) {
        return (value / 10000).toStringAsFixed(1) + '万';
      } else {
        return value.toString();
      }
    } else {
      if (int.parse(value) > 10000) {
        return (int.parse(value) / 10000).toStringAsFixed(1) + '万';
      } else {
        return int.parse(value).toString();
      }
    }
  }

  createAllList() {
    List<Widget> childrenList = <Widget>[];
    recommendList.forEach((element) => {
          if (element["creativeType"] == "scroll_playlist")
            {
              // 滚动
              childrenList.add(createScollItem(element))
            }
          else
            {
              childrenList
                  .add(createRecommendItem(element["resources"][0], true))
            }
        });
    return childrenList;
  }

  Widget createScollItem(item) {
    // 第一个滚动的歌单
    return Container(
      width: 100,
      margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
      child: Swiper(
        loop: true,
        autoplay: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, int index) {
          return createRecommendItem(item["resources"][index], false);
        },
        itemCount: item["resources"].length,
      ),
    );
  }

  Widget createRecommendItem(item, ismargin) {
    // 单个歌单
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/playlist',
          arguments: int.tryParse(item["resourceId"]),
        );
      },
      child: Container(
        width: 100,
        margin: ismargin
            ? EdgeInsets.fromLTRB(0, 10, 20, 0)
            : EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item["uiElement"]["image"]["imageUrl"] + '?param=100y100',
                    fit: BoxFit.cover,
                  ),
                ),
                // 右上角播放量
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            child: Image.asset(
                                "images/default/icon_event_video_play.png"),
                          ),
                          Text(
                            compCount(item["resourceExtInfo"]["playCount"]),
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              item["uiElement"]["mainTitle"]["title"],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
    // return Text(item["name"]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: 28,
                child: OutlinedButton(
                  onPressed: () => {},
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    )),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shape: MaterialStateProperty.all(
                      StadiumBorder(
                        side: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    '更多',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: createAllList(),
            ),
          ),
        ],
      ),
    );
  }
}
