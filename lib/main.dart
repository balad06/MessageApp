import 'package:MessageApp/pages/editMessage.dart';
import 'package:MessageApp/pages/managingMessages.dart';

import 'pages/homePage.dart';
import 'package:MessageApp/Message/Messages.dart';

import 'package:flutter/material.dart';

import 'login/auth.dart';
import 'login/loginscreen.dart';
import 'login/welcome.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp();

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ProxyProvider<Auth, Messages>(
          update: (ctx, auth, previousMessages) => Messages(
              auth.token,
              auth.userId,
              previousMessages == null ? [] : previousMessages.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          debugShowMaterialGrid: false,
          title: 'Comments',
          // theme: ThemeData(
          //   primarySwatch: Colors.lightGreen,
          //   accentColor: Colors.blueAccent,
          // ),
          home: auth.isAuth
              ? HomePage()
              : FutureBuilder(
                  future: auth.tryautoLogin(),
                  builder: (ctx, authResultSnapShots) =>
                      authResultSnapShots.connectionState ==
                              ConnectionState.waiting
                          ? WelcomePage()
                          : LoginPage(),
                ),
          routes: {
            LoginPage.id: (context) => LoginPage(),
            HomePage.id: (context) => HomePage(),
            UserMessageScreen.id: (context) => UserMessageScreen(),
            EditMessageScreen.id:(context) => EditMessageScreen(),
          },
        ),
      ),
    );
  }
}
