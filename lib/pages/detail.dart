import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_cnode/utils/request.dart';
import 'package:hello_cnode/models/detail.dart';
import 'package:hello_cnode/utils/utils.dart';
import 'package:hello_cnode/widgets/tips.dart';
import 'package:hello_cnode/widgets/detailContent.dart';
import 'package:hello_cnode/widgets/detailReplay.dart';
import 'package:hello_cnode/constants/index.dart';
import 'package:hello_cnode/widgets/loadingOrDefault.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String _token;
  Detail _detailData;
  bool _isFinish = false;
  bool _isCollect = false;

  Future<Null> _getDetailData(String id) async {
    final prefs = await Utils.preference();
    String _userToken = prefs.get('token');
    setState(() {
      _isFinish = false;
    });
    _detailData = await Request.getDetailData(id, _userToken);
    setState(() {
      _isFinish = true;
      _token = _userToken;
      _detailData = _detailData;
      _isCollect = _detailData.isCollect?? false;
    });
    return;
  }

  // 下拉刷新
  Future<Null> _pullRefresh() async {
    await _getDetailData(widget.id);
  }

  void _handleReload() {
    _getDetailData(widget.id);
  }

  // 帖子收藏
  Future<Null> _handleCollect() async {
    bool _isSuccess;
    bool _isCollected = false;
    if (_token == null) {
      await Tips.showCustomDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('请先登录哦!!!!'),
              actions: <Widget>[
                FlatButton(
                  child: Text("确认"),
                  onPressed: () async {
                    await Utils.scanQrCode(context, () {
                      Navigator.of(context).pop();
                      _getDetailData(widget.id);
                    });
                  },
                ),
              ],
            );
          });
      return;
    }
    if (_isCollect) {
      _isSuccess = await Request.unCollectContent(widget.id, _token);
    } else {
      _isSuccess = await Request.collectContent(widget.id, _token);
      _isCollected = _isSuccess;
    }
    if (_isSuccess) {
      await Tips.showCustomDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("提示"),
              content: Text("${_isCollected ? '收藏' : '取消收藏'}成功!!!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("确认"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getDetailData(widget.id);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _getDetailData(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_detailData?.title ?? '详情'),
          actions: <Widget>[
            InkWell(
              onTap: _handleCollect,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: _isCollect
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(Icons.favorite_border),
              ),
            )
          ],
        ),
        body: !_isFinish
            ? loading()
            : _detailData == null
                ? empty(_handleReload)
                : SafeArea(
                    child: RefreshIndicator(
                      onRefresh: _pullRefresh,
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              return detailContent(_detailData, context);
                            }, childCount: 1),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              return _detailData.replyCount == 0
                                  ? defaultContent(Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(bottom: 40),
                                      child: Text(NO_REPLY_CONTENT,
                                          style: TextStyle(
                                              fontSize: H2_SIZE,
                                              color: Colors.grey[400])),
                                    ))
                                  : detailReplay(
                                      _detailData.replies[index], context);
                            },
                                childCount: _detailData.replyCount == 0
                                    ? 1
                                    : _detailData.replyCount),
                          )
                        ],
                      ),
                    ),
                  ));
  }
}
