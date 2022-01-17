import 'package:flutter/material.dart';
import 'package:netease_app/http/request.dart';

class LiveScreenResultWidget extends StatefulWidget {
  final String name;
  LiveScreenResultWidget({Key? key, required this.name}) : super(key: key);

  @override
  _LiveScreenResultWidgetState createState() =>
      _LiveScreenResultWidgetState(name: this.name);
}

class _LiveScreenResultWidgetState extends State<LiveScreenResultWidget>
    with AutomaticKeepAliveClientMixin {
  final String name;
  _LiveScreenResultWidgetState({required this.name});

  var smallinfo;
  @override
  void initState() {
    super.initState();
    smallinfo = _getsmallTypeInfo();
  }

  @override
  bool get wantKeepAlive => true;

  _getsmallTypeInfo() async {
    Map<String, dynamic> params = {
      "shortName": name,
    };
    var data = await getdouyuSmallType(params);
    if (data["error"] == 0) {
      return data["data"];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: smallinfo,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            List _tablist = snapshot.data;
            if (_tablist.isNotEmpty) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1 / 1.2,
                  crossAxisSpacing: 10.0,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/livepage',
                        arguments: {
                          "tagid": _tablist[index]["tag_id"],
                          "typetitle": _tablist[index]["tag_name"],
                        },
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  _tablist[index]["icon_url"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _tablist[index]["tag_name"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    ),
                  );
                },
                itemCount: _tablist.length,
              );
            } else {
              return Container();
            }
          case ConnectionState.waiting:
          case ConnectionState.none:
          default:
            return Container();
        }
      },
    );
  }
}
