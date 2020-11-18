import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'message_model.dart';

class Messages with ChangeNotifier {
  List<Message> _items = [
  ];
  final String authToken;
  final String userId;
  Messages(this.authToken, this.userId, this._items);
  List<Message> get items {
    return [..._items];
  }

  List<Message> get readItems {
    return _items.where((prodItem) => prodItem.isRead).toList();
  }

  Message findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSet([bool filterByUser = false]) async {
    var url =
        'https://commentsflutter.firebaseio.com/Messages.json?auth=$authToken';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      } 
      url =
          'https://commentsflutter.firebaseio.com/userRead/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      var favoriteData = json.decode(favoriteResponse.body);
      print(userId);
      print(favoriteData);
      if (favoriteData == null) {
        favoriteData = {};
      }
      final List<Message> loadedMessages = [];
      extractedData.forEach((prodId, prodData) {
        if (filterByUser) {
          if (prodData['creatorId'] == userId) {
            loadedMessages.add(Message(
              id: prodId,
              message: prodData['message'],
              isRead: favoriteData[prodId] == null
                  ? false
                  : favoriteData[prodId] ?? false,
            ));
          }
        } else {
          loadedMessages.add(Message(
            id: prodId,
            message: prodData['message'],
            isRead: favoriteData[prodId] == null
                ? false
                : favoriteData[prodId] ?? false,
          ));
        }
      });
      _items = loadedMessages;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addMessage(Message message) async {
    final url =
        'https://commentsflutter.firebaseio.com/Messages.json?auth=$authToken';
    try {
      print('post');
      final response = await http.post(
        url,
        body: json.encode({
          'message': message.message,
          'creatorId': userId
        }),
      );
      print(response.body);
      final newMessage = Message(
        message: message.message,
        id: json.decode(response.body)['name'],
      );
      _items.add(newMessage);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateMessage(String id, Message newMessage) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://commentsflutter.firebaseio.com/Messages/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'message': newMessage.message,
          }));
      _items[prodIndex] = newMessage;
    } else {
      print('...');
    }
    notifyListeners();
  }

  void deleteMessage(String id) async {
    final url =
        'https://commentsflutter.firebaseio.com/Messages/$id.json?auth=$authToken';
    final existingMessageIndex = _items.indexWhere((prod) => prod.id == id);
    var existingMessage = _items[existingMessageIndex];
    _items.removeAt(existingMessageIndex);
    notifyListeners();
    final response = await http.delete(url);
    print(response.body);
    if (response.statusCode >= 400) {
      _items.insert(existingMessageIndex, existingMessage);
      notifyListeners();
      throw 'Could not delete';
    }
    existingMessage = null;
  }

  notifyListeners();
}
