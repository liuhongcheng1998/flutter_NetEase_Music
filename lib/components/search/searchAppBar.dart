// 搜索框

import 'package:flutter/material.dart';

GlobalKey<_SearchAppBarState> globalKey = GlobalKey();

// ignore: must_be_immutable
class SearchAppBar extends StatefulWidget {
  final String hintLabel; // 提示文字
  final String value;
  void Function(String)? callbackvalue;
  void Function(String)? submitcallback;
  void Function()? focusback;
  bool autofoucs;
  SearchAppBar(
      {Key? key,
      required this.hintLabel,
      required this.callbackvalue,
      required this.submitcallback,
      required this.focusback,
      this.autofoucs = true,
      this.value = ''})
      : super(key: key);

  @override
  _SearchAppBarState createState() => _SearchAppBarState(
      hintLabel: this.hintLabel,
      callbackvalue: this.callbackvalue,
      submitcallback: this.submitcallback,
      autofoucs: this.autofoucs,
      focusback: this.focusback,
      value: this.value);
}

class _SearchAppBarState extends State<SearchAppBar> {
  final String value;
  late FocusNode _focusNode; // 输入框控制器
  bool _offstage = true; // 偏移
  final TextEditingController _textEditingController = TextEditingController();
  final String hintLabel;
  void Function(String)? callbackvalue;
  void Function(String)? submitcallback;
  void Function()? focusback;
  bool autofoucs;
  _SearchAppBarState(
      {required this.hintLabel,
      required this.callbackvalue,
      required this.focusback,
      this.value = '',
      this.autofoucs = true,
      required this.submitcallback});
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController.addListener(() {
      var isVisible = _textEditingController.text.isNotEmpty;
      _updateDelIconVisible(isVisible);
    });
    if (value.isNotEmpty) {
      _textEditingController.text = value;
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        focusback!();
      }
    });
  }

  _updateDelIconVisible(bool isVisible) {
    setState(() {
      _offstage = !isVisible;
    });
  }

  moveFoucs() {
    _focusNode.unfocus();
  }

  setFoucs() {
    _focusNode.requestFocus();
  }

  clearValue() {
    _textEditingController.clear();
  }

  setValue(String value) {
    _textEditingController.text = value;
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              margin: EdgeInsets.only(left: 16),
              padding: EdgeInsets.only(left: 8, right: 9),
              decoration: BoxDecoration(
                color: Color.fromRGBO(246, 246, 246, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: Icon(
                      Icons.search,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: submitcallback,
                      onChanged: callbackvalue,
                      controller: _textEditingController,
                      autofocus: autofoucs,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      cursorColor: Colors.black87,
                      decoration: InputDecoration(
                        isCollapsed:
                            true, //重点，相当于高度包裹的意思，必须设置为true，不然有默认奇妙的最小高度
                        // contentPadding: EdgeInsets.symmetric(
                        //     horizontal: 8, vertical: 10), //内容内边距，影响高度
                        hintText: hintLabel,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black38,
                        ),
                      ),
                      maxLines: 1,
                    ),
                    flex: 1,
                  ),
                  Offstage(
                    offstage: _offstage,
                    child: GestureDetector(
                      onTap: () {
                        _textEditingController.clear();
                        callbackvalue!('');
                        _focusNode.unfocus();
                      },
                      child: Container(
                        child: Icon(
                          Icons.cancel,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            flex: 1,
          ),
          GestureDetector(
            onTap: () {
              // 取消返回上一页
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
