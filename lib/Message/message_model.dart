import 'package:flutter/foundation.dart';

class Message with ChangeNotifier {
  final String id;
  final String message;
  bool isRead;

  Message({
    @required this.id,
    @required this.message,
    this.isRead = false,
  });

  
}