import 'package:MessageApp/Message/Messages.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/usermessage.dart';
import './editMessage.dart';

// import '../widgets/user_product_item.dart';
// import './edit_product_screen.dart';

class UserMessageScreen extends StatefulWidget {
  static const id = '/user-messages';

  @override
  _UserMessageScreenState createState() => _UserMessageScreenState();
}

class _UserMessageScreenState extends State<UserMessageScreen> {
  var _isinit = true;
  var _isLoading = false;
  Future<void> _refreshMessages() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Messages>(context, listen: false)
        .fetchAndSet(true)
        .then((_) {
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
      Provider.of<Messages>(context).fetchAndSet(true).then((_) {
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
    final messagesData = Provider.of<Messages>(context);
    return Scaffold(
      appBar: Topbar(
        'Your Messages',
        [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditMessageScreen.id);
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshMessages(),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: messagesData.items.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      UserMessageItem(
                        messagesData.items[i].id,
                        messagesData.items[i].message,
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
