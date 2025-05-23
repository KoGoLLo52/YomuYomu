import 'dart:typed_data';

import 'package:yomuyomu/models/manga_model.dart';

abstract class FileViewContract {
  void showImagesInMemory(List<Uint8List> imageData);
  void showMangaDetails(MangaModel manga) {}
  void showError(String message);
}

