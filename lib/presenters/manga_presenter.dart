import 'dart:io';

import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/handler/cbz_handler.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/manga_model.dart';

class FileViewModel {
  final FileViewContract view;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final allowedExtensions = ['cbz'];

  FileViewModel(this.view);

  /// Abre un archivo completo (todo el .cbz)
  Future<void> openFileFromLocation(String filePath) async {
    try {
      if (!await _databaseHelper.requestStoragePermission()) {
        view.showError("Storage permission denied.");
        return;
      }

      final ext = filePath.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(ext)) {
        view.showError("The selected file is not a valid CBZ file.");
        return;
      }

      final file = File(filePath);
      final cbzHandler = CBZHandler(file);
      final chapterMap = await cbzHandler.extractChaptersInMemory();

      // Cargar imágenes de todos los capítulos juntos (por ejemplo, para vista previa)
      final allImages = chapterMap.values.expand((list) => list.map((img) => img.data)).toList();

      if (allImages.isEmpty) {
        view.showError("No valid images found in the CBZ file.");
        return;
      }

      final fileName = file.uri.pathSegments.last;
      final title = fileName.replaceAll(RegExp(r'\.(cbz)$'), '');
      final existing = await _databaseHelper.getMangaByTitle(title);

      if (existing == null) {
        final newManga = Manga(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          coverUrl: '', // Puedes guardar la imagen en memoria o generar una URI si la extraes
          genres: [],
          status: MangaStatus.ongoing,
          authorId: "unknown",
          totalChaptersAmount: chapterMap.length,
          rating: 0.0,
          chapterProgress: 0,
          synopsis: "",
          startPublicationDate: DateTime.now(),
        );
        await _databaseHelper.insertManga(newManga.toMap());
      }

      view.showImagesInMemory(allImages);
    } catch (e) {
      view.showError("There was an error opening the file: $e");
    }
  }

  /// Abre un capítulo específico
  Future<void> openSpecificChapter(String filePath, String chapterId) async {
    try {
      if (!await _databaseHelper.requestStoragePermission()) {
        view.showError("Storage permission denied.");
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        view.showError("File does not exist at the given path.");
        return;
      }

      final cbzHandler = CBZHandler(file);
      final images = await cbzHandler.extractImagesByChapter(chapterId);

      if (images.isEmpty) {
        view.showError("No images found for chapter $chapterId.");
        return;
      }

      view.showImagesInMemory(images);
    } catch (e) {
      view.showError("Failed to open chapter $chapterId: $e");
    }
  }

  Future<void> loadMangaDetails(String mangaID) async {
    try {
      final mangaData = await _databaseHelper.getMangaById(mangaID);
      if (mangaData == null) {
        view.showError("Manga not found.");
        return;
      }

      final manga = Manga.fromMap(mangaData);
      view.showMangaDetails(manga);
    } catch (e) {
      view.showError("Error loading manga details: $e");
    }
  }
}
