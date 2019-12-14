import 'package:flutter/material.dart';
import 'package:hello_cnode/constants/index.dart';
import 'package:hello_cnode/routes/routeParams.dart';

Widget drawerPage(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: UnconstrainedBox(
            child: Container(
                width: 100.0,
                height: 100.0,
                child: ClipOval(
                  child: Image.asset(AUTHOR_AVATAR,
                      height: 100, fit: BoxFit.cover),
                )),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/webview',
                        arguments: ToWebView(
                            WEB_VIEW_BASE_URL + 'cWatermelon', '@chenc'));
                  },
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: "作者: ", style: TextStyle(fontSize: H2_SIZE)),
                    TextSpan(
                      text: " @chenc",
                      style: TextStyle(color: Colors.blue, fontSize: H2_SIZE),
                    ),
                  ])),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text('职业: 前端', style: TextStyle(fontSize: H2_SIZE)),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text('爱好: 吃饭, 睡觉, 钓鱼', style: TextStyle(fontSize: H2_SIZE)),
              )
            ],
          ),
        )
      ],
    ),
  );
}
