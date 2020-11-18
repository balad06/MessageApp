import 'package:MessageApp/Message/Messages.dart';

import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../login/auth.dart';
import 'package:MessageApp/widgets/messageItem.dart';

class HomePage extends StatefulWidget {
  static const id = '/homePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _isinit = true;
  var _isLoading = false;
  bool _setReadValue(bool newValue) {
    bool isRead = newValue;
    return isRead;
  }

  Future<bool> toggleRead(
      String token, String userId, String id, bool isRead) async {
    final oldStatus = isRead;
    print('post');
    isRead = true;
    print(isRead);
    final url =
        'https://commentsflutter.firebaseio.com/userRead/$userId/$id.json?auth=$token';
    try {
      final response1= await http.get(url);
      var data = json.decode(response1.body);
      print(data);
      final response = await http.put(
        url,
        body: json.encode(
          isRead,
        ),
      );
      if (response.statusCode >= 400) {
        isRead = _setReadValue(oldStatus);
      }
    } catch (error) {
      isRead = _setReadValue(oldStatus);
    }
    return Future<bool>.value(isRead);
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Messages>(context, listen: false).fetchAndSet().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Messages>(context).fetchAndSet().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final message = Provider.of<Message>(context, listen: false);
    final messageData = Provider.of<Messages>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      appBar: Topbar('Messages', []),
      drawer: MainDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : messageData.items.length == 0
              ? LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'No Messages yet!',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          // Container(
                          //     height: constraints.maxHeight * 0.7,
                          //     child: Image.asset(
                          //       'assets/images/waiting.png',
                          //       fit: BoxFit.cover,
                          //     )),
                        ],
                      ),
                    );
                  },
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshMessages(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: messageData.items.length,
                          itemBuilder: (ctx, i) => Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MessageItem(messageData.items[i]),
                              messageData.items[i].isRead
                                  ? Container()
                                  : FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          messageData.items[i].isRead =
                                              !messageData.items[i].isRead;
                                          toggleRead(
                                              authData.token,
                                              authData.userId,
                                              messageData.items[i].id,
                                              messageData.items[i].isRead);
                                        });
                                        //  messageData.items[i].isRead
                                      },
                                      child: Text('Mark as Read'),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
