import 'package:yomuyomu/models/chapter_model.dart';
import 'package:yomuyomu/models/manga_model.dart';

abstract class MangaDetailViewContract {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showManga(MangaModel manga);
  void showChapters(List<Chapter> chapters);
}