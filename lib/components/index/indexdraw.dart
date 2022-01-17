// 用户左侧抽屉

import 'package:flutter/material.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:provider/provider.dart';

class UserLeftDrawPage extends StatefulWidget {
  UserLeftDrawPage({Key? key}) : super(key: key);

  @override
  _UserLeftDrawPageState createState() => _UserLeftDrawPageState();
}

class _UserLeftDrawPageState extends State<UserLeftDrawPage> {
  late bool islogin;

  var userinfo;

  @override
  void initState() {
    super.initState();
    islogin = Provider.of<DefaultProvider>(context, listen: false).islogin;
    userinfo = Provider.of<DefaultProvider>(context, listen: false).userInfo;
  }

  gettitleShow() {
    if (islogin) {
      return Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5, left: 10),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color.fromRGBO(244, 240, 242, 1),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(width: 1, color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.network(
                '${userinfo["avatarUrl"]}?param=100y100',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(1, 1)),
              padding: MaterialStateProperty.all(
                EdgeInsets.all(5),
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${userinfo["nickname"]}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 1),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                    size: 24,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 5, left: 10),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color.fromRGBO(244, 240, 242, 1),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(width: 1, color: Colors.black12),
            ),
            child: Icon(
              Icons.person,
              color: Color.fromRGBO(244, 216, 213, 1),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(1, 1)),
              padding: MaterialStateProperty.all(
                EdgeInsets.all(5),
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '立即登录',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                // Icon(
                //   Icons.chevron_right,
                //   color: Colors.black,
                //   size: 24,
                // ),
                Transform.translate(
                  offset: Offset(0, 1),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                    size: 24,
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }
  }

  // ==========vip==========
  createVipBox() {
    if (islogin) {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(57, 57, 57, 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "开通黑胶VIP",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                    ),
                    Text(
                      "立享超21项专属特权 >",
                      style: TextStyle(
                        color: Color.fromRGBO(136, 132, 133, 1),
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                // 会员中心的按钮
                Container(
                  height: 20,
                  child: OutlinedButton(
                    onPressed: () => {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      textStyle: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    child: Text(
                      '会员中心',
                      style: TextStyle(
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.5,
              color: Color.fromRGBO(136, 132, 133, 1),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "受邀专享，黑胶VIP低至0.04元/天",
                    style: TextStyle(
                      color: Color.fromRGBO(136, 132, 133, 1),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              flex: 1,
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(57, 57, 57, 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "开通黑胶VIP",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                    ),
                    Text(
                      "立享超21项专属特权 >",
                      style: TextStyle(
                        color: Color.fromRGBO(136, 132, 133, 1),
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                // 会员中心的按钮
                Container(
                  height: 20,
                  child: OutlinedButton(
                    onPressed: () => {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      textStyle: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    child: Text(
                      '会员中心',
                      style: TextStyle(
                        color: Color.fromRGBO(249, 232, 233, 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 0.5,
              color: Color.fromRGBO(136, 132, 133, 1),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "受邀专享，黑胶VIP低至0.04元/天",
                    style: TextStyle(
                      color: Color.fromRGBO(136, 132, 133, 1),
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              flex: 1,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: double.infinity,
        color: Color.fromRGBO(241, 241, 241, 1),
        child: ListView(
          children: [
            gettitleShow(),
            SizedBox(
              height: 10,
            ),
            // 黑胶信息
            createVipBox(),
            SizedBox(
              height: 10,
            ),
            // 菜单
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.mail_outline,
                    ),
                    onTap: () => {},
                    title: Transform.translate(
                      offset: Offset(-25, 0),
                      child: Text(
                        "消息中心",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.shield,
                    ),
                    onTap: () => {},
                    title: Transform.translate(
                      offset: Offset(-25, 0),
                      child: Text(
                        "云贝中心",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),
            // 其他
            SizedBox(
              height: 10,
            ),
            // 菜单
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                    child: Text(
                      '其他',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                    ),
                    onTap: () => {},
                    title: Transform.translate(
                      offset: Offset(-25, 0),
                      child: Text(
                        "设置",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.access_alarm,
                    ),
                    onTap: () => {},
                    title: Transform.translate(
                      offset: Offset(-25, 0),
                      child: Text(
                        "定时关闭",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),
            // 如果是登录状态则有个退出登录的按钮
            islogin
                ? Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.white,
                        ),
                        elevation: MaterialStateProperty.all(0),
                      ),
                      child: Text(
                        '退出登录',
                        style: TextStyle(
                          color: Colors.red,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
