import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final instance = Preferences._();

  late SharedPreferences prefs;

  Preferences._();

  String get fcmToken => prefs.getString("fcmToken") ?? '';

  int get version => prefs.getInt("version") ?? 0;

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setFcmToken(String token) => prefs.setString("fcmToken", token);

  Future<void> setVersion(int version) => prefs.setInt("version", version);
}
