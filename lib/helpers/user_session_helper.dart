import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class UserSession {
  static const String _localUserIdKey = 'userID';
  static String? _cachedUserId;

  static Future<String> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;

    final prefs = await SharedPreferences.getInstance();
    final localUserId = prefs.getString(_localUserIdKey);

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      final firebaseUserId = firebaseUser.uid;

      if (localUserId == null) {
        await prefs.setString(_localUserIdKey, firebaseUserId);
      } else if (localUserId != firebaseUserId) {
        await DatabaseHelper.instance.migrateUserData(
          localUserId,
          firebaseUserId,
        );
        await prefs.setString(_localUserIdKey, firebaseUserId);
      }

      _cachedUserId = firebaseUserId;
      return firebaseUserId;
    }

    if (localUserId != null) {
      _cachedUserId = localUserId;
      return localUserId;
    } else {
      final newUuid = const Uuid().v4();
      await prefs.setString(_localUserIdKey, newUuid);
      _cachedUserId = newUuid;
      return newUuid;
    }
  }

  static Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localUserIdKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localUserIdKey);
    _cachedUserId = null;
  }
}
