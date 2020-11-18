import 'package:MessageApp/Message/Messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/managingMessages.dart';
import '../pages/editMessage.dart';


class UserMessageItem extends StatelessWidget {
  // static const id ='userproduct';
  final String id;
  final String message;

  UserMessageItem(this.id, this.message );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditMessageScreen.id, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Provider.of<Messages>(context, listen: false).deleteMessage(id);
                Navigator.of(context).pushReplacementNamed(UserMessageScreen.id);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
