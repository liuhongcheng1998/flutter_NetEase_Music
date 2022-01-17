// 搜索提示页

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:netease_app/http/request.dart';

// ignore: must_be_immutable
class SearchTipsWigdet extends StatefulWidget {
  String searchValue;
  void Function(String) callbackvalue;
  void Function(String) changefocus;
  SearchTipsWigdet({
    Key? key,
    required this.searchValue,
    required this.callbackvalue,
    required this.changefocus,
  }) : super(key: key);

  @override
  _SearchTipsWigdetState createState() => _SearchTipsWigdetState(
      searchValue: this.searchValue,
      callbackvalue: this.callbackvalue,
      changefocus: this.changefocus);
}

class _SearchTipsWigdetState extends State<SearchTipsWigdet> {
  String searchValue;

  void Function(String) callbackvalue;

  void Function(String) changefocus;
  _SearchTipsWigdetState({
    required this.searchValue,
    required this.callbackvalue,
    required this.changefocus,
  });
  var searchList;

  @override
  void initState() {
    super.initState();
    searchList = _getSearchTipsList();
  }

  _getSearchTipsList() async {
    var params = {
      "keywords": searchValue,
      "type": "mobile",
    };
    var data = await getSearchTipsList(params);
    if (data["code"] == 200) {
      return data["result"]["allMatch"];
    } else {
      return [];
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      searchValue = widget.searchValue;
      searchList = _getSearchTipsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: FutureBuilder(
        future: searchList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  '无结果!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
              ),
            );
          }

          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.builder(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/searchresult',
                              arguments: snapshot.data[index]["keyword"])
                          .then((res) {
                        if (res != null) {
                          if (res is Map) {
                            if (res["name"] == 'searchreslut') {
                              print('这里触发了${res["value"]}');
                              // 如果到这里的话说明是在搜索结果页点击了搜索输入框
                              // 需要告诉主页面聚焦并且将输入框的值改为传过来的值
                              changefocus(res["value"]);
                            }
                          }
                        } else {
                          callbackvalue(snapshot.data[index]["keyword"]);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 30,
                          padding: EdgeInsets.fromLTRB(16, 5, 16, 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.black38,
                                size: 14,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data[index]["keyword"],
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  );
                },
                itemCount: snapshot.data.length,
              );
            case ConnectionState.waiting:
              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: Container(
                    height: 20,
                    width: 20,
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineScale,
                      colors: const [Colors.red],
                    ),
                  ),
                ),
              );
            case ConnectionState.none:
            default:
              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    '无结果!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
