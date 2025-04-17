import 'dart:io';

abstract class FileViewContract {
  void showError(String message);
  void showImages(List<File> images);
}
