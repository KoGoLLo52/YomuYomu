import 'dart:io';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MangaModel {
  Future<List<File>> extract(File compressedFile) async {
    final bytes = await compressedFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final tempDir = await getTemporaryDirectory();
    List<File> imageFiles = [];

    for (final file in archive) {
      if (!file.isFile) continue;
      final filename = file.name.toLowerCase();
      if (filename.endsWith('.jpg') || filename.endsWith('.png')) {
        final data = file.content as List<int>;
        final output = File('${tempDir.path}/${file.name}');
        await output.writeAsBytes(data);  // Escribe la imagen extraída
        imageFiles.add(output);
      }
    }

    imageFiles.sort((a, b) => a.path.compareTo(b.path));
    return imageFiles;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) return true;

      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // En iOS no es necesario el permiso
  }
}
