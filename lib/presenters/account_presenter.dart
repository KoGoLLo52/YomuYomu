import 'package:yomuyomu/contracts/account_contract.dart';
import 'package:yomuyomu/models/account_model.dart';

class AccountPresenter implements AccountPresenterContract {
  final AccountViewContract _view;

  AccountPresenter(this._view);

  @override
  void loadUserData() {
    // Simulación de datos (debería venir de un repositorio real)
    final data = AccountModel(
      username: 'MangaFan123',
      dateOfCreation: '2022-01-15',
      mostReadGenre: 'Shonen',
      mostReadAuthor: 'Masashi Kishimoto',
      favoriteMangaUrls: [
        'assets/naruto1.jpg',
        'assets/bluelock.jpg',
        'assets/naruto2.jpg',
        'assets/naruto3.jpg',
        'assets/mha.jpg',
      ],
      finishedMangasCount: 12,
      commentsPosted: 45,
    );

    _view.updateUserInfo(data.username, data.dateOfCreation);
    _view.updateActivity(
      mostReadGenre: data.mostReadGenre,
      mostReadAuthor: data.mostReadAuthor,
      favoriteMangas: data.favoriteMangaUrls,
      finishedCount: data.finishedMangasCount,
      commentsPosted: data.commentsPosted,
    );
  }
}
