import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_app/notification_service.dart';
import 'package:smart_app/preferences.dart';
import 'package:smart_app/status_checker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    NotificationService.instance.setContext(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: _WebView(),
        ),
      ),
    );
  }
}

class _WebView extends StatelessWidget {
  const _WebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: checkPermission(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return _webView();
        });
  }

  Widget _webView() {
    const domain = 'https://smartapp.kingsu.com.tw';
    const path = '/index/wapp';
    final query = 'sendtoken=${Preferences.instance.fcmToken}';

    log('ready to build web view');

    return WebView(
      initialUrl: '$domain$path?$query',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
