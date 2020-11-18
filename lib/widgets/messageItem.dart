import 'package:flutter/material.dart';
import '../Message/message_model.dart';
// import 'package:provider/provider.dart';
// import '../login/auth.dart';

class MessageItem extends StatefulWidget {
  final Message message;

  MessageItem(this.message);

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text('${widget.message.message}'),
        subtitle:
            widget.message.isRead ? Text('Message Read') : Text('Yet to read'),
      ),
    );
  }
}
