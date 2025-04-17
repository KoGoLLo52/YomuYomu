import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../contracts/library_contract.dart';
import '../models/manga.dart';

class LibraryPresenter implements LibraryPresenterContract {
  final LibraryViewContract view;

  List<Manga> _allMangas = [];

  LibraryPresenter(this.view);

  @override
  Future<void> loadMangas() async {
    // Mock data
    _allMangas = [
      Manga(
        title: "One Piece",
        author: "Eiichiro Oda",
        sinopsis:
            "Un joven pirata sueña con convertirse en el Rey de los Piratas.",
        rating: 4.9,
        startPublicationDate: DateTime(1997, 7, 22),
        nextPublicationDate: DateTime(2025, 4, 21),
        genres: ["Action", "Fantasy"],
        status: "Pending",
        chapterProgress: 1080,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Attack on Titan",
        author: "Hajime Isayama",
        sinopsis:
            "Humanidad atrapada entre muros frente a titanes devoradores.",
        rating: 4.8,
        startPublicationDate: DateTime(2009, 9, 9),
        nextPublicationDate: DateTime(2021, 4, 9),
        genres: ["Action", "Drama", "Mystery"],
        status: "Completed",
        chapterProgress: 139,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "My Hero Academia",
        author: "Kohei Horikoshi",
        sinopsis: "Un joven sin poderes lucha por ser el héroe número uno.",
        rating: 4.5,
        startPublicationDate: DateTime(2014, 7, 7),
        nextPublicationDate: DateTime(2025, 4, 18),
        genres: ["Action", "Superhero", "Shonen"],
        status: "Pending",
        chapterProgress: 420,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Tokyo Revengers",
        author: "Ken Wakui",
        sinopsis: "Un joven viaja al pasado para salvar a su novia.",
        rating: 4.2,
        startPublicationDate: DateTime(2017, 3, 1),
        nextPublicationDate: DateTime(2022, 11, 16),
        genres: ["Action", "Drama", "Time Travel"],
        status: "Completed",
        chapterProgress: 278,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Chainsaw Man",
        author: "Tatsuki Fujimoto",
        sinopsis: "Un cazador de demonios con motosierra en la cabeza.",
        rating: 4.6,
        startPublicationDate: DateTime(2018, 12, 3),
        nextPublicationDate: DateTime(2025, 4, 23),
        genres: ["Horror", "Action", "Supernatural"],
        status: "Pending",
        chapterProgress: 165,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Death Note",
        author: "Tsugumi Ohba",
        sinopsis: "Un estudiante encuentra un cuaderno con poder mortal.",
        rating: 4.9,
        startPublicationDate: DateTime(2003, 12, 1),
        nextPublicationDate: DateTime(2006, 5, 15),
        genres: ["Thriller", "Mystery", "Supernatural"],
        status: "Completed",
        chapterProgress: 108,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Jujutsu Kaisen",
        author: "Gege Akutami",
        sinopsis:
            "Un estudiante lucha contra maldiciones con energía espiritual.",
        rating: 4.7,
        startPublicationDate: DateTime(2018, 3, 5),
        nextPublicationDate: DateTime(2025, 4, 22),
        genres: ["Action", "Supernatural", "Dark Fantasy"],
        status: "Pending",
        chapterProgress: 260,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Demon Slayer",
        author: "Koyoharu Gotouge",
        sinopsis: "Un joven intenta salvar a su hermana convertida en demonio.",
        rating: 4.8,
        startPublicationDate: DateTime(2016, 2, 15),
        nextPublicationDate: DateTime(2020, 5, 18),
        genres: ["Action", "Historical", "Supernatural"],
        status: "Completed",
        chapterProgress: 205,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Spy x Family",
        author: "Tatsuya Endo",
        sinopsis: "Un espía, una asesina y una telépata fingen ser familia.",
        rating: 4.6,
        startPublicationDate: DateTime(2019, 3, 25),
        nextPublicationDate: DateTime(2025, 4, 22),
        genres: ["Comedy", "Action", "Slice of Life"],
        status: "Pending",
        chapterProgress: 95,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Blue Lock",
        author: "Muneyuki Kaneshiro",
        sinopsis: "Una competencia brutal para encontrar al mejor delantero.",
        rating: 4.3,
        startPublicationDate: DateTime(2018, 8, 1),
        nextPublicationDate: DateTime(2025, 4, 20),
        genres: ["Sports", "Psychological", "Drama"],
        status: "Pending",
        chapterProgress: 260,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Solo Leveling",
        author: "Chugong",
        sinopsis: "El cazador más débil se convierte en el más fuerte.",
        rating: 4.8,
        startPublicationDate: DateTime(2018, 3, 4),
        nextPublicationDate: DateTime(2021, 12, 29),
        genres: ["Action", "Fantasy", "RPG"],
        status: "Completed",
        chapterProgress: 179,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Noragami",
        author: "Adachitoka",
        sinopsis:
            "Un dios menor busca seguidores resolviendo problemas humanos.",
        rating: 4.4,
        startPublicationDate: DateTime(2010, 12, 1),
        nextPublicationDate: DateTime(2025, 4, 25),
        genres: ["Action", "Supernatural", "Comedy"],
        status: "Pending",
        chapterProgress: 107,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Black Clover",
        author: "Yūki Tabata",
        sinopsis: "Un chico sin magia lucha por ser el Rey Mago.",
        rating: 4.5,
        startPublicationDate: DateTime(2015, 2, 16),
        nextPublicationDate: DateTime(2025, 4, 21),
        genres: ["Magic", "Adventure", "Shonen"],
        status: "Pending",
        chapterProgress: 370,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Dr. Stone",
        author: "Riichiro Inagaki",
        sinopsis: "La humanidad revive tras miles de años petrificada.",
        rating: 4.6,
        startPublicationDate: DateTime(2017, 3, 6),
        nextPublicationDate: DateTime(2022, 3, 7),
        genres: ["Science", "Adventure", "Shonen"],
        status: "Completed",
        chapterProgress: 232,
        isStarred: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
      Manga(
        title: "Bakuman",
        author: "Tsugumi Ohba",
        sinopsis: "Dos jóvenes sueñan con ser mangakas exitosos.",
        rating: 4.7,
        startPublicationDate: DateTime(2008, 8, 11),
        nextPublicationDate: DateTime(2012, 4, 23),
        genres: ["Drama", "Slice of Life", "Shonen"],
        status: "Completed",
        chapterProgress: 176,
        isStarred: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
    ];
    view.updateMangaList(_allMangas);
  }

  @override
  void filterByStatus(String status) {
    final filtered = _allMangas.where((m) => m.status == status).toList();
    view.updateMangaList(filtered);
  }

  @override
  void filterByGenres(List<String> genres) {
    final filtered =
        _allMangas
            .where((m) => m.genres.any((g) => genres.contains(g)))
            .toList();
    view.updateMangaList(filtered);
  }

  @override
  void sortBy(String criteria) {
    List<Manga> sorted = [..._allMangas];
    switch (criteria) {
      case "Alphabetically":
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      // Agrega otros criterios
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