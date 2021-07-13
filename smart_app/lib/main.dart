import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

String fcmToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  late FirebaseMessaging messaging;

  _saveFCMToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("fcmToken", token);
  }

  _getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("fcmToken") != null) {
      fcmToken = prefs.getString("fcmToken")!;
    }
  }

  _getFCMToken();
  messaging = FirebaseMessaging.instance;

  messaging.getToken().then((value) {
    if (value != null) {
      _saveFCMToken(value);
      fcmToken = value;
    }
    print("fcm token:"+value!);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Notification.instance.setContext(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  static final location = Location();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
        future: location.hasPermission(),
        builder: (context, snapshot) {
          print('permission: ${snapshot.data}');
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final status = snapshot.data!;
          final permit = status == PermissionStatus.granted ||
              status == PermissionStatus.grantedLimited;

          return permit ? _webView() : _request();
        });
  }

  Widget _webView() {
    print('start web view');

    return WebView(
      initialUrl: 'https://smartapp.kingsu.com.tw/index/wapp?sendtoken=$fcmToken',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  Widget _request() {
    print('start request permission');

    return FutureBuilder(
        future: Future.wait([
          location.requestPermission(),
          FirebaseMessaging.instance.requestPermission(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return _webView();
        });
  }
}

class Notification {
  static final Notification instance = Notification._();

  BuildContext? context;

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }
  }

  Notification._() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final messages = <String>[
          message.notification?.title ?? '',
          message.notification?.body ?? '',
        ].where((e) => e != '').map<Widget>((e) => Text(e));

        if (messages.isEmpty) return;

        final snackBar = SnackBar(content: Column(children: messages.toList()));

        ScaffoldMessenger.of(context!).showSnackBar(snackBar);
      }
    });
  }
}
