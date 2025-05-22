import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPresenter implements AccountPresenterContract {
  final AccountViewContract _view;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final email = currentUser.email;
    if (email == null || !_isValidEmail(email)) return null;

    var userMap = await _databaseHelper.getUserByEmail(email);

    // Si no existe, lo guardamos nuevo
    if (userMap == null) {
      await saveUserToDatabase(currentUser.displayName ?? 'Usuario', email);
      userMap = await _databaseHelper.getUserByEmail(email);
      if (userMap == null) return null;
    } else {
      final updatedUser = AccountModel(
        userID: userMap['UserID'],
        username: currentUser.displayName ?? userMap['Username'],
        email: email,
        icon: userMap['Icon'] ?? 'default_user_pfp.png',
        creationDate: DateTime(
          userMap['CreationDate'],
        ),
        syncStatus: userMap['SyncStatus'] ?? 0,
        mostReadGenre: '', // o puedes mantener alguno si está en userMap
        mostReadAuthor: '',
        favoriteMangaCovers: [],
        finishedMangasCount: 0,
        commentsPosted: 0,
      );

      await _databaseHelper.updateUser(updatedUser.toMap(), updatedUser.userID);
      userMap = updatedUser.toMap();
    }

    // Extra data
    final comments = await _databaseHelper.getAllComments();
    final notes = await _databaseHelper.getAllUserNotes();

    final favoritedCovers =
        notes
            .where((n) => n['IsFavorited'] == 1)
            .take(5)
            .map((n) => Uri.parse(n['MangaID'] as String))
            .toList();

    return AccountModel.fromMap({
      ...userMap,
      'MostReadGenre': 'Shonen',
      'MostReadAuthor': 'Autor Ejemplo',
      'FavoriteMangaCovers': favoritedCovers,
      'FinishedMangasCount': notes.where((n) => n['IsPending'] == 0).length,
      'CommentsPosted':
          comments.where((c) => c['UserID'] == userMap!['UserID']).length,
    });
  }

  @override
  Future<void> saveUserToDatabase(String username, String email) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final user = AccountModel(
      userID: currentUser.uid,
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

    await _databaseHelper.insertUser(user.toMap());
  }

  bool _isValidEmail(String email) {
    final invalidDomains = ['local.a'];
    final regex = RegExp(r'^[\w\.-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    final domain = email.split('@').last;
    return regex.hasMatch(email) && !invalidDomains.contains(domain);
  }
}
