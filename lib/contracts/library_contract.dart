import 'package:yomuyomu/models/author_model.dart';
import 'package:yomuyomu/models/manga_model.dart';

abstract class LibraryViewContract {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void updateMangaList(List<MangaModel> mangas);
  void updateAuthorList(Map<String, Author> authorMap);
}

abstract class LibraryPresenterContract {
  void loadMangas();
  void filterByStatus(List<MangaStatus> status);
  void filterByGenres(List<String> genres);
  void sortBy(int criteria);
}
