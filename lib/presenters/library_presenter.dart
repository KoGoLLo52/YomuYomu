import 'dart:io';
import 'package:path/path.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/models/author_model.dart';
import 'package:yomuyomu/models/chapter_model.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/panel_model.dart';

class LibraryPresenter implements LibraryPresenterContract {
  final LibraryViewContract view;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Manga> _allMangas = [];
  List<Manga> _filtered = [];

  List<Author> _allAuthor = [];

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

      final authorData = await _databaseHelper.getAllAuthors();

      _allAuthor =
          authorData.map((map) {
            return Author.fromMap(map);
          }).toList();
      final Map<String, Author> authorMap = {
        for (var author in _allAuthor) author.authorId: author,
      };
      view.updateMangaList(_allMangas);
      view.updateAuthorList(authorMap);
      view.hideLoading();
    } catch (e) {
      view.showError("Error loading manga library: $e");
    }
  }

  Future<void> importCBZFile({required bool isVolume}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final appDir = await getApplicationDocumentsDirectory();
    final cbzDir = Directory(join(appDir.path, 'cbz'));

    if (!await cbzDir.exists()) await cbzDir.create(recursive: true);

    final fileName = basename(file.path);
    final newCBZPath = join(cbzDir.path, fileName);

    final destinationFile = File(newCBZPath);
    if (await destinationFile.exists()) {
      await destinationFile.delete();
    }

    final copiedFile = await file.copy(newCBZPath);

    final regex = RegExp(
      r'^(.*?)\s+v(\d+)\s+\((\d{4})\)\s+\((.*?)\)\s+\((.*?)\)\.cbz$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(fileName);

    if (isVolume && match == null) {
      print("Formato de nombre no reconocido para volumen.");
      return;
    }

    final title =
        isVolume ? match!.group(1)!.trim() : basenameWithoutExtension(fileName);
    final volumeNumber = isVolume ? int.tryParse(match!.group(2)!) : null;
    final publicationDate =
        isVolume ? DateTime.tryParse('${match!.group(3)!}-01-01') : null;
    final genres =
        isVolume
            ? match!.group(5)!.trim().split(',').map((e) => e.trim()).toList()
            : <String>[];

    final mangaId = title.replaceAll(' ', '_').toLowerCase();

    final db = DatabaseHelper.instance;
    final existing = await db.getMangaById(mangaId);
    if (existing == null) {
      await db.insertManga(
        Manga(
          id: mangaId,
          title: title,
          authorId: 'unknown',
          genres: genres,
          synopsis: 'Descripción no disponible.',
          rating: 0.0,
          startPublicationDate: publicationDate!,
          totalChaptersAmount: 0,
        ).toMap(),
      );
      print('📌 Manga "$title" insertado.');
    }

    final inputStream = InputFileStream(copiedFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    final baseExtractPath = join(cbzDir.path, title.replaceAll(' ', '_'));

    final Map<String, List<Panel>> chaptersPanelsMap = {};
    String? volumeCoverPath;

    final panelFileRegex = RegExp(
      r' - c(\d+)\s+\(v\d+\)\s+-\s+p(\d+)(?:-p(\d+))?(?: \[.*?\])*?\.(jpg|jpeg|png)$',
      caseSensitive: false,
    );

    for (final file in archive) {
      if (!file.isFile) continue;

      final extension = file.name.toLowerCase();
      if (!(extension.endsWith('.jpg') ||
          extension.endsWith('.jpeg') ||
          extension.endsWith('.png'))) {
        continue;
      }

      final match = panelFileRegex.firstMatch(file.name);
      if (isVolume && match == null) {
        print("Archivo no cumple con patrón esperado: ${file.name}");
        continue;
      }

      final chapterNumberStr = isVolume ? match!.group(1)! : '1';
      final panelNumberStr =
          isVolume ? match!.group(2)! : file.name.hashCode.toString();

      final chapterId = '${title.replaceAll(' ', '_')}_c$chapterNumberStr';
      final chapterDirPath = join(baseExtractPath, 'c$chapterNumberStr');

      final chapterDir = Directory(chapterDirPath);
      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      final outPath = join(chapterDirPath, basename(file.name));
      final outFile = File(outPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);

      if (isVolume && file.name.contains('p000') && volumeCoverPath == null) {
        volumeCoverPath = outPath;
        await db.updateMangaCover(mangaId, volumeCoverPath);
      }

      final panel = Panel(
        id: '${chapterId}_p$panelNumberStr',
        chapterId: chapterId,
        index: int.tryParse(panelNumberStr) ?? 0,
        filePath: outFile.path,
      );

      chaptersPanelsMap.putIfAbsent(chapterId, () => []).add(panel);
    }

    final List<Chapter> chapters = [];

    await db.updateMangaChapterCount(mangaId, chaptersPanelsMap.length);

    for (var entry in chaptersPanelsMap.entries) {
      final chapterId = entry.key;
      final panels = entry.value..sort((a, b) => a.index.compareTo(b.index));
      final chapterNumber =
          int.tryParse(
            RegExp(r'c(\d+)$').firstMatch(chapterId)?.group(1) ?? '1',
          ) ??
          1;

      final chapter = Chapter(
        id: chapterId,
        mangaId: mangaId,
        chapterNumber: chapterNumber,
        panelsCount: panels.length,
        panels: panels,
        title:
            isVolume
                ? 'Vol. ${volumeNumber ?? 1} - Capítulo $chapterNumber'
                : 'Capítulo $chapterNumber',
        publicationDate: publicationDate,
        coverUrl:
            isVolume
                ? volumeCoverPath
                : panels.first.filePath, // 🔸 Usamos la portada del volumen
      );

      await db.insertChapter(chapter.toMap());

      for (final panel in panels) {
        await db.insertPanel(panel.toMap());
      }

      chapters.add(chapter);
    }

    print('✅ Importados ${chapters.length} capítulos para el manga "$title".');
    for (var chap in chapters) {
      print(
        '📖 Capítulo ${chap.chapterNumber} con ${chap.panelsCount} paneles',
      );
    }
    await loadMangas();
  }

  String extensionFromPath(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return path.substring(dotIndex);
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
