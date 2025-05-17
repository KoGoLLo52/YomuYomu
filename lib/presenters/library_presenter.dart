import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/helpers/database_helper.dart';

class LibraryPresenter implements LibraryPresenterContract {
  final LibraryViewContract view;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Manga> _allMangas = [];
  List<Manga> _filtered = [];

  LibraryPresenter(this.view);

  @override
  @override
  Future<void> loadMangas() async {
    try {
      view.showLoading();
      final prefs = await SharedPreferences.getInstance();
      
      String? userId = prefs.getString('userId');
      final mangaData = await _databaseHelper.getAllMangas();

      _allMangas =
          mangaData.map((map) {
            return Manga.fromMap(map);
          }).toList();

      _filtered = _allMangas;

      view.updateMangaList(_allMangas);
      view.hideLoading();
    } catch (e) {
      view.showError("Error loading manga library: $e");
    }
  }

  void showAll() {
    _filtered = _allMangas;
    view.updateMangaList(_filtered);
  }

  @override
  void filterByStatus(List<MangaStatus> statusList) {
    _filtered = _allMangas.where((m) => statusList.contains(m.status)).toList();
    view.updateMangaList(_filtered);
  }

  @override
  void filterByGenres(List<String> genres) {
    _filtered =
        _allMangas
            .where((m) => m.genres.any((g) => genres.contains(g)))
            .toList();
    view.updateMangaList(_filtered);
  }

  void filterMangasByTitle(String query) {
    _filtered =
        _allMangas.where((manga) {
          return manga.title.toLowerCase().contains(query.toLowerCase()) ||
              manga.authorId.toLowerCase().contains(query.toLowerCase());
        }).toList();

    view.updateMangaList(_filtered.isEmpty ? _allMangas : _filtered);
  }

  @override
  void sortBy(int criteria) {
    List<Manga> sorted = [..._filtered.isNotEmpty ? _filtered : _allMangas];

    switch (criteria) {
      case 0:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 1:
        sorted.sort(
          (a, b) => b.totalChaptersAmount.compareTo(a.totalChaptersAmount),
        );
        break;
      case 2:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    view.updateMangaList(sorted);
  }

  Future<String> getValidfilePath(String filename) async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    } else if (Platform.isWindows) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    return '${directory.path}/$filename';
  }
}
