import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChangeLyricWight extends StatefulWidget {
  var callback;
  bool isshow;
  ChangeLyricWight({Key? key, required this.callback, required this.isshow})
      : super(key: key);

  @override
  _ChangeLyricWightState createState() => _ChangeLyricWightState(
        callback: this.callback,
        isshow: this.isshow,
      );
}

class _ChangeLyricWightState extends State<ChangeLyricWight> {
  var callback;
  bool isshow;
  _ChangeLyricWightState({required this.callback, required this.isshow});

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isshow != widget.isshow) {
      setState(() {
        isshow = widget.isshow;
        callback = widget.callback;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isshow,
      child: GestureDetector(
        onTap: () {
          callback();
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
    );
  }
}
