import 'package:yomuyomu/contracts/manga_detail_contract.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/chapter_model.dart';
import 'package:yomuyomu/models/manga_model.dart';

class MangaDetailPresenter {
  final MangaDetailViewContract _view;
  Manga? _manga;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  MangaDetailPresenter(this._view);

  Future<void> loadMangaDetail(String mangaID) async {
    try {
      final mangaData = await _databaseHelper.getMangaById(mangaID);
      if (mangaData == null) {
        _view.showError("Manga no encontrado");
        return;
      }

      _manga = Manga(
        id: mangaData['MangaID'],
        title: mangaData['Title'],
        authorId: mangaData['AuthorID'],
        synopsis: mangaData['Synopsis'],
        rating: (mangaData['Rating'] ?? 0).toDouble(),
        startPublicationDate: DateTime.fromMillisecondsSinceEpoch(mangaData['StartPublicationDate']),
        nextPublicationDate: mangaData['NextPublicationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(mangaData['NextPublicationDate'])
            : null,
        totalChaptersAmount: mangaData['Chapters'],
        chapters: await _loadChapters(mangaID),
      );

      _view.showManga(_manga!);
      _view.showChapters(_manga!.chapters ?? []);
    } catch (e) {
      _view.showError("Error al cargar el manga: $e");
    }
  }

  Future<List<Chapter>> _loadChapters(String mangaID) async {
    try {
      final chaptersData = await _databaseHelper.getChaptersByMangaId(mangaID);
      return chaptersData.map((chapterData) {
        return Chapter.fromMap(chapterData);
      }).toList();
    } catch (e) {
      _view.showError("Error al cargar los capítulos: $e");
      return [];
    }
  }

  void searchChapter(String query) {
    final chapters = _manga?.chapters;
    if (chapters == null || chapters.isEmpty) {
      _view.showChapters([]);
      return;
    }

    final results = chapters
        .where((c) => c.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();

    _view.showChapters(results);
  }
}
