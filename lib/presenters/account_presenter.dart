import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/enums/reading_status.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/helpers/user_session_helper.dart';
import 'package:yomuyomu/models/account_model.dart';
import 'package:yomuyomu/models/usernote_model.dart'; 

class AccountPresenter implements AccountPresenterContract {
  final AccountViewContract _view;
  final DatabaseHelper _db = DatabaseHelper();

  AccountPresenter(this._view);

  @override
  Future<void> loadUserData() async {
    try {
      _view.showLoading();

      final account = await _getUserAccount();
      if (account == null) {
        _view.showError('No se encontraron datos de usuario.');
        return;
      }

      _view.updateAccount(account);
    } catch (e) {
      _view.showError('Error cargando datos del usuario: $e');
    } finally {
      _view.hideLoading();
    }
  }

  Future<AccountModel?> _getUserAccount() async {
    final userId = await UserSession.getUserId();

    if (userId.isEmpty) return null;

    // Aquí la parte del email depende de Firebase, para eso podrías agregar otro método en UserSession
    // que te devuelva el email si hay sesión Firebase o null si no
    // Para este ejemplo, asumiremos que lo obtienes igual con FirebaseAuth, 
    // pero puedes hacerlo más robusto luego

    final currentUser = FirebaseAuth.instance.currentUser;
    final email = currentUser?.email;

    if (email == null || !_isValidEmail(email)) return null;

    final prefs = await SharedPreferences.getInstance();
    final oldID = prefs.getString('old_user_id');

    var userMap = await _db.getUserByEmail(email);

    if (userMap == null) {
      if (oldID != null && oldID != userId) {
        await _db.migrateUserData(oldID, userId);
      }

      await saveUserToDatabase(currentUser?.displayName ?? 'Usuario', email);
      userMap = await _db.getUserByEmail(email);
      if (userMap == null) return null;
    } else {
      final updatedUser = AccountModel(
        userID: userId,
        username: currentUser?.displayName ?? userMap['Username'],
        email: email,
        icon: userMap['Icon'] ?? 'default_user_pfp.png',
        creationDate: DateTime(userMap['CreationDate']),
        syncStatus: userMap['SyncStatus'] ?? 0,
        mostReadGenre: '',
        mostReadAuthor: '',
        favoriteMangaCovers: [],
        finishedMangasCount: 0,
        commentsPosted: 0,
      );

      await _db.updateUser(updatedUser.toMap(), updatedUser.userID);
      userMap = updatedUser.toMap();
    }

    await prefs.setString('old_user_id', userId);

    final comments = await _db.getAllComments();
    final List<UserNote> notes = await _db.getUserNotes(userId);

    final List<UserNote> safeNotes = notes;

    final List<Uri> favoritedCovers = safeNotes
        .where((note) => note.isFavorited)
        .take(5)
        .map((note) => Uri.parse(note.mangaId))
        .toList();

    final int finishedCount = safeNotes.where((note) => note.readingStatus == ReadingStatus.completed).length;

    final String userIdFromMap = userMap['UserID'] as String;
    final int commentCount = comments.where((c) => c['UserID'] == userIdFromMap).length;

    return AccountModel.fromMap({
      ...userMap,
      'MostReadGenre': 'Shonen',
      'MostReadAuthor': 'Autor Ejemplo',
      'FavoriteMangaCovers': favoritedCovers,
      'FinishedMangasCount': finishedCount,
      'CommentsPosted': commentCount,
    });
  }

  @override
  Future<void> saveUserToDatabase(String username, String email) async {
    final userId = await UserSession.getUserId();
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
      commentsPosted: 0,
    );

    await _db.insertUser(user.toMap());
  }

  bool _isValidEmail(String email) {
    final invalidDomains = ['local.a'];
    final regex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    final domain = email.split('@').last;
    return regex.hasMatch(email) && !invalidDomains.contains(domain);
  }
}
