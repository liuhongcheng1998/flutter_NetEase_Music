// 登录页

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_app/provider/default_provider.dart';
import 'package:provider/provider.dart';

class UserLoginPage extends StatefulWidget {
  UserLoginPage({Key? key}) : super(key: key);

  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 创建表单唯一索引
  Map<String, dynamic> _edituinfo = {
    "phone": '',
    "password": '',
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 40,
            right: 40,
            top: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    ZoomIn(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'images/default/icon_logo.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    FadeIn(
                      delay: Duration(milliseconds: 300),
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text(
                          '欢迎使用!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 34,
                          ),
                        ),
                      ),
                    ),
                    FadeIn(
                      delay: Duration(milliseconds: 300),
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          'flutter 仿网易云音乐',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '请输入手机号',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white38,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_iphone,
                          color: Colors.white,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '请填写手机号';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        _edituinfo["phone"] = value;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      obscureText: true,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: '请输入登录密码',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white38,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white38,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '请填写登录密码';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        _edituinfo["password"] = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Consumer<DefaultProvider>(
                builder: (context, usermodel, child) {
                  return Container(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var params = {
                            "phone": _edituinfo["phone"],
                            "password": _edituinfo["password"],
                          };
                          usermodel.loginByPhone(params).then((value) {
                            if (value["code"] == 200) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (route) => false);
                            } else {
                              print('失败');
                            }
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        elevation: MaterialStateProperty.all(0),
                        overlayColor: MaterialStateProperty.all(
                            Color.fromRGBO(0, 0, 0, 0.08)),
                        shape: MaterialStateProperty.all(
                          StadiumBorder(
                            side: BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                      child: Text(
                        '立即登录',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
