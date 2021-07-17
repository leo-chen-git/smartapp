import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();

  BuildContext? context;

  NotificationService._() {
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

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }
  }
}
