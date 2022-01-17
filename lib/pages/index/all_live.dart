// 直播

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/components/live/live_list_refresh.dart';

class LiveAllPage extends StatefulWidget {
  String tagid;
  String typetitle;
  LiveAllPage({Key? key, this.tagid = '', this.typetitle = '推荐直播'})
      : super(key: key);

  @override
  _LiveAllPageState createState() => _LiveAllPageState();
}

class _LiveAllPageState extends State<LiveAllPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.typetitle,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        actions: [
          widget.tagid.isEmpty
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/livescreen');
                  },
                  icon: Icon(
                    Icons.menu_rounded,
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: 10),
        child: LiveListFreshWidget(
          url: widget.tagid,
        ),
      ),
    );
  }
}
