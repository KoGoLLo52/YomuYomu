import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:yomuyomu/Account/contracts/account_contract.dart';
import 'package:yomuyomu/Mangas/enums/reading_status.dart';
import 'package:yomuyomu/DataBase/database_helper.dart';
import 'package:yomuyomu/Account/helpers/user_session_helper.dart';
import 'package:yomuyomu/Account/model/account_model.dart';
import 'package:yomuyomu/Mangas/models/usernote_model.dart';

class AccountPresenter implements AccountPresenterContract {
  final AccountViewContract _view;
  final DatabaseHelper _db = DatabaseHelper();
  StreamSubscription<User?>? _authSubscription;

  AccountPresenter(this._view);

  void initSessionListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (user != null) {
        await loadUserData();
      } else {
        _view.updateAccount(null);
      }
    });
  }

  @override
  Future<void> loadUserData() async {
    try {
      _view.showLoading();

      final account = await _getUserAccount();
      _view.updateAccount(account);
    } catch (e) {
      _view.showError('Error cargando datos del usuario: $e');
    } finally {
      _view.hideLoading();
    }
  }

  Future<AccountModel?> _getUserAccount() async {
    final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    if (firebaseUser == null ||
        firebaseUser.email == null ||
        !_isValidEmail(firebaseUser.email!)) {
      return null;
    }

    final userId = await UserSession.getUserId();
    if (userId.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final oldID = prefs.getString('old_user_id');

    Map<String, dynamic>? userMap = await _db.getUserByEmail(
      firebaseUser.email!,
    );

    if (userMap == null) {
      if (oldID != null && oldID != userId) {
        await _db.migrateUserData(oldID, userId);
      }

      await saveUserToDatabase(
        firebaseUser.displayName ?? 'Usuario',
        firebaseUser.email!,
      );
      userMap = await _db.getUserByEmail(firebaseUser.email!);
      if (userMap == null) return null;
    }

    await prefs.setString('old_user_id', userId);

    final List<UserNote> notes = await _db.getUserNotes(userId);
    final List<String> favoritedCovers = await _db.getFavoriteMangaCovers(
      userId,
    );

    final int finishedCount =
        notes
            .where((note) => note.readingStatus == ReadingStatus.completed)
            .length;

    return AccountModel.fromMap({
      ...userMap,
      'MostReadGenre': 'Shonen',
      'MostReadAuthor': 'Autor Ejemplo',
      'FavoriteMangaCovers': favoritedCovers,
      'FinishedMangasCount': finishedCount,
    });
  }

  @override
  Future<void> saveUserToDatabase(String username, String email) async {
    final String userId = await UserSession.getUserId();
    if (userId.isEmpty) return;

    final user = AccountModel(
      userID: userId,
      username: username,
      email: email,
      icon: 'default_user_pfp.png',
      creationDate: DateTime.now(),
      syncStatus: 0,
      mostReadGenre: '',
      mostReadAuthor: '',
      favoriteMangaCovers: [],
      finishedMangasCount: 0,
    );

    await _db.insertUser(user.toMap());
  }

  @override
  Future<void> logout() async {
    String oldID = await UserSession.getUserId();
    await FirebaseAuth.instance.signOut();

    String newID = const Uuid().v4();
    if (oldID != newID) {
      await _db.migrateUserData(oldID, newID);
    }
    _view.updateAccount(null);
    _view.showError("Sesión cerrada.");
  }

  bool _isValidEmail(String email) {
    const invalidDomains = ['local.a'];
    final regex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    final domain = email.split('@').last;
    return regex.hasMatch(email) && !invalidDomains.contains(domain);
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}
