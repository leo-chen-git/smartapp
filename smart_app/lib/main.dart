// @Dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:location_permissions/location_permissions.dart' as l;
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

String fcmToken = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  /// Create an Android Notification Channel.
  /// 這裡有多使用套件: flutter_local_notifications: ^3.0.3
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  // AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // requesting permission
  l.PermissionStatus requestPermissions = await l.LocationPermissions().requestPermissions();
  l.PermissionStatus checkPermissionStatus = await l.LocationPermissions().checkPermissionStatus();
  print("PermissionStatus:"+ requestPermissions.toString());
  print("checkPermissionStatus:"+ checkPermissionStatus.toString());

  WidgetsFlutterBinding.ensureInitialized();
// Obtain a list of the available cameras on the device.
  Permission.camera.request();
  Permission.storage.request();

  final cameras = await availableCameras();
  print("cameras.isEmpty:"+ cameras.isEmpty.toString());

// Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
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
    runApp(MyApp());
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message ${message.messageId}");
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartApp',
      home: MyHomePage(title: 'SmartApp Home Page'),
    );
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  // late FirebaseMessaging messaging;
  // String fcmToken = "";

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    print(""
        ".build: " + 'https://smartapp.kingsu.com.tw/index/wapp?sendtoken=$fcmToken');
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.0), // here the desired height
          child: AppBar(
            backgroundColor: Colors.black,
          )
      ),

      body: WebView(
        initialUrl: 'https://smartapp.kingsu.com.tw/index/wapp?sendtoken=$fcmToken',
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
      )
      // body: WebviewScaffold(
      //   url: 'https://smartapp.kingsu.com.tw/index/wapp?sendtoken=$fcmToken',
      //   withLocalStorage: true,
      //   withZoom: true,
      //   geolocationEnabled: true,
      //   withJavascript: true,
      // ),
    );
  }
}
