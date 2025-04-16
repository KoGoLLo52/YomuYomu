import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yomuyomu/main.dart';

Future<void> pickAndOpen(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['cbz', 'cbr'],
    );

    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final file = File(path);

    final images = await extract(file);

    if (!context.mounted) return;

    if (images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CBZViewer(images: images)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find valid images in the file')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }
}


Future<List<File>> extract(File compressedFile) async {
  final bytes = await compressedFile.readAsBytes();
  final archive = ZipDecoder().decodeBytes(bytes);

  final tempDir = await getTemporaryDirectory();
  List<File> image = [];

  for (final file in archive) {
    if (!file.isFile) continue;
    final filename = file.name.toLowerCase();

    if(filename.endsWith('.jpg') || filename.endsWith('.png')) {
      final data = file.content as List<int>;
      final output = File('${tempDir.path}/${file.name}');

      await output.writeAsBytes(data);
      image.add(output);
    }
  }

  image.sort((a,b) => a.path.compareTo(b.path));

  return image; 
}