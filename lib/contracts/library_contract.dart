import 'package:yomuyomu/models/manga.dart';

abstract class LibraryViewContract {
  void updateMangaList(List<Manga> mangas);
}

abstract class LibraryPresenterContract {
  void loadMangas();
  void filterByStatus(List<MangaStatus> status);
  void filterByGenres(List<String> genres);
  void sortBy(int criteria);
}
