import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/account_model.dart';

class AccountPresenter implements AccountPresenterContract {
  final AccountViewContract _view;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  AccountPresenter(this._view);

  @override
  Future<void> loadUserData() async {
    try {
      _view.showLoading();

      final userMap = await _getUserAccountData();
      if (userMap == null) {
        _view.showError('No se encontraron datos de usuario.');
        return;
      }

      final account = AccountModel.fromMap(userMap);

      _view.updateUserInfo(
        account.username,
        _formatDate(account.creationDate),
      );

      _view.updateActivity(
        mostReadGenre: account.mostReadGenre,
        mostReadAuthor: account.mostReadAuthor,
        favoriteMangas: account.favoriteMangaCovers.map((e) => e.toString()).toList(),
        finishedCount: account.finishedMangasCount,
        commentsPosted: account.commentsPosted,
      );

    } catch (e) {
      _view.showError('Error cargando datos del usuario: $e');
    } finally {
      _view.hideLoading();
    }
  }

  Future<Map<String, dynamic>?> _getUserAccountData() async {
    final users = await _databaseHelper.getAllUsers();
    final user = users.isNotEmpty ? users.first : null;

    if (user == null) return null;

    final comments = await _databaseHelper.getAllComments();
    final notes = await _databaseHelper.getAllUserNotes();

    final favoritedCovers = notes
        .where((n) => n['IsFavorited'] == 1)
        .take(5)
        .map((n) => n['MangaID'] as String)
        .toList();

    return {
      'Username': user['Username'],
      'CreationDate': user['CreationDate'],
      'MostReadGenre': 'Shonen',
      'MostReadAuthor': 'Autor Ejemplo',
      'FavoriteMangaCovers': favoritedCovers,
      'FinishedMangasCount': notes.where((n) => n['IsPending'] == 0).length,
      'CommentsPosted': comments.where((c) => c['UserID'] == user['UserID']).length,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
