import '../widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Message/message_model.dart';
import '../Message/Messages.dart';

class EditMessageScreen extends StatefulWidget {
  static const id = '/edit-Message';

  @override
  _EditMessageScreenState createState() => _EditMessageScreenState();
}

class _EditMessageScreenState extends State<EditMessageScreen> {
  final _messageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedMessage = Message(
    id: null,
    message: '',
  );
  bool isLoading = false;
  var _initValues = {
    'message':'',
  };
  var _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final messageId = ModalRoute.of(context).settings.arguments as String;
      if (messageId != null) {
        _editedMessage =
            Provider.of<Messages>(context, listen: false).findById(messageId);
        _initValues = {
          'message': _editedMessage.message,
          // 'imageUrl': _editedMessage.imageUrl,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _messageFocusNode.dispose();
    super.dispose();
  }


  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (_editedMessage.id != null) {
      await Provider.of<Messages>(context, listen: false)
          .updateMessage(_editedMessage.id, _editedMessage);
      // setState(() {
      //   isLoading = false;
      // });
      // Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Messages>(context, listen: false)
            .addMessage(_editedMessage);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error Occured'),
            content: Text('Something Went Wrong'),
            actions: <Widget>[
              FlatButton(
                child: Text('okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
       setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Topbar(
        'Edit Messages',
        [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                   
                    TextFormField(
                      initialValue: _initValues['message'],
                      decoration: InputDecoration(labelText: 'message'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _messageFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a message.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedMessage = Message(
                          message: value,
                          id: _editedMessage.id,
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
