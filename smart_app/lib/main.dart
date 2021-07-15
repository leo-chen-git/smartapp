import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Prefs.instance.initialize();

  if (Prefs.instance.fcmToken.isEmpty) {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      Prefs.instance.fcmToken = token;
    }
    print("request fcm token: ${token ?? ''}");
  }

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
    const domain = 'https://smartapp.kingsu.com.tw';
    const path = '/index/wapp';
    final query = 'sendtoken=${Prefs.instance.fcmToken}';

    return WebView(
      initialUrl: '$domain$path?$query',
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

class Prefs {
  static final instance = Prefs._();

  late SharedPreferences prefs;

  Prefs._();

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  String get fcmToken => prefs.getString("fcmToken") ?? '';
  set fcmToken(String token) => prefs.setString("fcmToken", token);
}
