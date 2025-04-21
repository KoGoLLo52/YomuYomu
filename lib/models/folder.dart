import 'package:yomuyomu/models/manga.dart';

class Folder {
  String name;
  List<Manga> mangas; // Lista de mangas dentro de la carpeta
  Map<String, Folder> subfolders; // Subcarpetas dentro de esta carpeta

  Folder({required this.name})
      : mangas = [],
        subfolders = {};

  // Agregar un manga a la carpeta
  void addManga(Manga manga) {
    mangas.add(manga);
  }

  // Crear una subcarpeta
  void addSubfolder(String subfolderName) {
    if (!subfolders.containsKey(subfolderName)) {
      subfolders[subfolderName] = Folder(name: subfolderName);
    }
  }

  // Agregar un manga a una subcarpeta
  void addMangaToSubfolder(String subfolderName, Manga manga) {
    if (subfolders.containsKey(subfolderName)) {
      subfolders[subfolderName]?.addManga(manga);
    }
  }
}
