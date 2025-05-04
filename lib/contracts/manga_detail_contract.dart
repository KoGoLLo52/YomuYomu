import 'package:yomuyomu/models/manga.dart';

abstract class MangaDetailViewContract {
  void showManga(Manga manga);
  void showChapters(List<Chapter> chapters);
}