// 精选视频

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SelectedVideoPage extends StatefulWidget {
  List videoList;
  SelectedVideoPage({Key? key, required this.videoList}) : super(key: key);

  @override
  _SelectedVideoPageState createState() =>
      _SelectedVideoPageState(videoList: this.videoList);
}

class _SelectedVideoPageState extends State<SelectedVideoPage> {
  List videoList;
  _SelectedVideoPageState({required this.videoList});

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

  createVideoItem(item) {
    return Container(
      width: 100,
      margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item["resource"]["mlogBaseData"]["coverUrl"] +
                        '?param=100y150',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                          compCount(item["resource"]["mlogExtVO"]["playCount"]),
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    "images/default/icon_event_play.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            item["resource"]["mlogBaseData"]["text"],
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
                '精选音乐视频',
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
                    '换一批',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return createVideoItem(videoList[index]);
              },
              itemCount: videoList.length,
            ),
          ),
        ],
      ),
    );
  }
}
