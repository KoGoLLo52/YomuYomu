import 'dart:io';

import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/models/manga_model.dart';

class FileViewModel {
  final FileViewContract view;
  final MangaModel model = MangaModel();
  final allowedExtensions = ['cbz', 'cbr'];

  FileViewModel(this.view);

  Future<void> openFileFromLocation(String filePath) async {
    try {
      if (!await model.requestStoragePermission()) {
        view.showError("Storage permission denied.");
        return;
      }

      final ext = filePath.split('.').last.toLowerCase();

      if (!allowedExtensions.contains(ext)) {
        view.showError("The selected file is not a valid CBZ/CBR file.");
        return;
      }

      final file = File(filePath);

      final images = await model.extract(file);

      if (images.isEmpty) {
        view.showError("No valid images found in the file.");
      } else {
        view.showImages(images);
      }
    } catch (e) {
      view.showError("There was an error opening the file: $e");
    }
  }
}
