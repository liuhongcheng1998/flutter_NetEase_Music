// 音乐日历

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MusicCalenderPage extends StatefulWidget {
  List calenderList;
  MusicCalenderPage({Key? key, required this.calenderList}) : super(key: key);

  @override
  _MusicCalenderPageState createState() =>
      _MusicCalenderPageState(calenderList: this.calenderList);
}

class _MusicCalenderPageState extends State<MusicCalenderPage> {
  List calenderList;
  _MusicCalenderPageState({required this.calenderList});

  createlistitem() {
    List<Widget> itemlist = <Widget>[];
    calenderList.forEach((element) {
      itemlist.add(createitems(element["resources"][0]));
      itemlist.add(Divider());
    });

    return itemlist;
  }

  filterTime(end) {
    var endtime = DateTime.fromMillisecondsSinceEpoch(end);
    var nowday = DateTime.now();
    if (endtime.year == nowday.year &&
        endtime.month == nowday.month &&
        endtime.day == nowday.day) {
      return Text('今天');
    } else {
      return Text('${endtime.month}-${endtime.day}');
    }
  }

  filterTags(end, taglist) {
    // print('taglist$taglist');
    List<Widget> tags = <Widget>[];
    tags.add(filterTime(end));
    taglist.forEach((element) {
      tags.add(Container(
        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
        margin: EdgeInsets.only(right: 5),
        color: Color.fromRGBO(189, 127, 104, 0.1),
        child: Text(
          element,
          style: TextStyle(
            color: Color.fromRGBO(189, 127, 104, 1),
            fontSize: 12,
          ),
        ),
      ));
    });
    return tags;
  }

  createitems(item) {
    // print('音乐日历$item');
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: filterTags(item["resourceExtInfo"]["endTime"],
                    item["resourceExtInfo"]["tags"] ?? []),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                item["uiElement"]["mainTitle"]["title"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            ],
          ),
        ),
        Container(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(item["uiElement"]["image"]["imageUrl"]),
          ),
        ),
      ],
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
                '音乐日历',
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
          Divider(),
          Column(
            children: createlistitem(),
          ),
        ],
      ),
    );
  }
}
