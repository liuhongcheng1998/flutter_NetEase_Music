// 首页发现 - 个性推荐

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PersonalityPage extends StatefulWidget {
  var personalityInfo;
  PersonalityPage({Key? key, required this.personalityInfo}) : super(key: key);

  @override
  _PersonalityPageState createState() =>
      _PersonalityPageState(personalityInfo: this.personalityInfo);
}

class _PersonalityPageState extends State<PersonalityPage> {
  var personalityInfo;
  _PersonalityPageState({required this.personalityInfo});

  createColumList(item) {
    List<Widget> songItemList = <Widget>[];
    item["resources"].forEach((element) {
      songItemList.add(SizedBox(
        height: 10,
      ));
      songItemList.add(createItem(element));
    });
    return songItemList;
  }

  filterartists(List artists) {
    String artistList = '';
    artists.forEach((element) {
      artistList += element["name"] + '/';
    });
    return artistList.substring(0, artistList.length - 1);
  }

  filtersubTitle(item) {
    if (item["titleType"] == "songRcmdTag") {
      // 说明这是一个标签
      return Container(
        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
        child: Text(
          item["title"],
          style: TextStyle(
            color: Color.fromRGBO(189, 127, 104, 1),
            fontSize: 10,
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Text(
          item["title"],
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.6),
            fontSize: 12,
          ),
        ),
      );
    }
  }

  createItem(item) {
    return Container(
      width: double.infinity,
      height: 60,
      child: Row(
        children: [
          // 图片
          Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                item["uiElement"]["image"]["imageUrl"] + '?param=60y60',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 上下文字
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item["uiElement"]["mainTitle"]["title"],
                      ),
                      // 跟上艺术家
                      TextSpan(
                          text:
                              ' -  ${filterartists(item["resourceExtInfo"]["artists"])}',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.38),
                            fontSize: 10,
                          ))
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                filtersubTitle(item["uiElement"]["subTitle"] ??
                    {"titleType": '', "title": ""}),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12),
                      ),
                    ),
                  ),
                )
              ],
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
                personalityInfo["uiElement"]["subTitle"]["title"],
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
                    '播放',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            height: 210,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.95,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                  child: Column(
                    children:
                        createColumList(personalityInfo["creatives"][index]),
                  ),
                );
              },
              itemCount: personalityInfo["creatives"].length,
            ),
          )
        ],
      ),
    );
  }
}
