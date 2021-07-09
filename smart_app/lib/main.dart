import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var fcmToken = prefs.getString("fcmToken");

  if (fcmToken == null) {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      prefs.setString("fcmToken", token);
    }
    fcmToken = token;
  }

  runApp(MyApp(fcmToken ?? ''));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message ${message.messageId}");
}

class MyApp extends StatelessWidget {
  final String fcmToken;

  MyApp(this.fcmToken, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: WebView(
          initialUrl:
              'https://smartapp.kingsu.com.tw/index/wapp?sendtoken=$fcmToken',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
