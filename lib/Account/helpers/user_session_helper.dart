import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:yomuyomu/DataBase/database_helper.dart';

class UserSession {
  static const String _localUserIdKey = 'userID';
  static String? _cachedUserId;
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<String> getUserId() async {
    await _initPrefs();

    if (_cachedUserId != null) return _cachedUserId!;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _cachedUserId = firebaseUser.uid;
      return firebaseUser.uid;
    }

    final storedId = _prefs!.getString(_localUserIdKey);
    if (storedId != null) {
      _cachedUserId = storedId;
      return storedId;
    }

    final newUuid = const Uuid().v4();
    await _prefs!.setString(_localUserIdKey, newUuid);
    _cachedUserId = newUuid;
    return newUuid;
  }

  static Future<String> getStoredUserId() async {
    await _initPrefs();
    String? userId = await DatabaseHelper.instance.getSingleUserID();
    if(userId == null){
      return 'localhost';
    }
    return userId;
  }

  /// Limpia el ID local
  static Future<void> clear() async {
    await _initPrefs();
    await _prefs!.remove(_localUserIdKey);
    _cachedUserId = null;
  }
}

