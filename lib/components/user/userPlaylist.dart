import 'package:flutter/material.dart';
import 'package:netease_app/style/textstyle.dart';

// ignore: must_be_immutable
class UserPlayListWidget extends StatefulWidget {
  List playList;
  bool iscreate;
  UserPlayListWidget({Key? key, required this.playList, required this.iscreate})
      : super(key: key);

  @override
  _UserPlayListWidgetState createState() => _UserPlayListWidgetState(
      playList: this.playList, iscreate: this.iscreate);
}

class _UserPlayListWidgetState extends State<UserPlayListWidget> {
  List playList;
  bool iscreate;
  _UserPlayListWidgetState({required this.playList, required this.iscreate});
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      playList = widget.playList;
      iscreate = widget.iscreate;
    });
  }

  _createItems() {
    List<Widget> itemsList = playList.map((item) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/playlist', arguments: item["id"]);
        },
        child: Container(
          height: 60,
          padding: EdgeInsets.only(left: 16, right: 16),
          margin: EdgeInsets.only(
            bottom: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${item["coverImgUrl"]}?param=100y100',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        item["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      Row(
                        children: [
                          Text(
                            '${item["trackCount"]}首音乐 ',
                            style: songsubtitle,
                          ),
                          iscreate
                              ? Text(
                                  "by ${item["creator"]["nickname"]} ,  ",
                                  style: songsubtitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
      );
    }).toList();
    return itemsList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _createItems(),
    );
  }
}
