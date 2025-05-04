import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/models/manga.dart';

class LibraryPresenter implements LibraryPresenterContract {
  final LibraryViewContract view;

  List<Manga> _allMangas = [];
  List<Manga> filtered = [];

  LibraryPresenter(this.view);

  @override
  Future<void> loadMangas() async {
    // Mock data
    _allMangas = [
      Manga(
        title: "Attack on Titan",
        author: "Hajime Isayama",
        sinopsis:
            "Humanidad atrapada entre muros frente a titanes devoradores.",
        rating: 4.8,
        startPublicationDate: DateTime(2009, 9, 9),
        nextPublicationDate: DateTime(2021, 4, 9),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Drama", "Mystery"],
        status: MangaStatus.completed,
        totalChaptersAmount: 139,
        chapterProgress: 139,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "My Hero Academia",
        author: "Kohei Horikoshi",
        sinopsis: "Un joven sin poderes lucha por ser el héroe número uno.",
        rating: 4.5,
        startPublicationDate: DateTime(2014, 7, 7),
        nextPublicationDate: DateTime(2025, 4, 18),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Superhero", "Shonen"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 420,
        chapterProgress: 420,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Tokyo Revengers",
        author: "Ken Wakui",
        sinopsis: "Un joven viaja al pasado para salvar a su novia.",
        rating: 4.2,
        startPublicationDate: DateTime(2017, 3, 1),
        nextPublicationDate: DateTime(2022, 11, 16),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Drama", "Time Travel"],
        status: MangaStatus.completed,
        totalChaptersAmount: 278,
        chapterProgress: 278,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Death Note",
        author: "Tsugumi Ohba",
        sinopsis: "Un estudiante encuentra un cuaderno con poder mortal.",
        rating: 4.9,
        startPublicationDate: DateTime(2003, 12, 1),
        nextPublicationDate: DateTime(2006, 5, 15),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Thriller", "Mystery", "Supernatural"],
        status: MangaStatus.completed,
        totalChaptersAmount: 108,
        chapterProgress: 108,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
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
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Supernatural", "Dark Fantasy"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 260,
        chapterProgress: 260,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Demon Slayer",
        author: "Koyoharu Gotouge",
        sinopsis: "Un joven intenta salvar a su hermana convertida en demonio.",
        rating: 4.8,
        startPublicationDate: DateTime(2016, 2, 15),
        nextPublicationDate: DateTime(2020, 5, 18),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Historical", "Supernatural"],
        status: MangaStatus.completed,
        totalChaptersAmount: 205,
        chapterProgress: 205,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Spy x Family",
        author: "Tatsuya Endo",
        sinopsis: "Un espía, una asesina y una telépata fingen ser familia.",
        rating: 4.6,
        startPublicationDate: DateTime(2019, 3, 25),
        nextPublicationDate: DateTime(2025, 4, 22),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Comedy", "Action", "Slice of Life"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 95,
        chapterProgress: 95,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Blue Lock",
        author: "Muneyuki Kaneshiro",
        sinopsis: "Una competencia brutal para encontrar al mejor delantero.",
        rating: 4.3,
        startPublicationDate: DateTime(2018, 8, 1),
        nextPublicationDate: DateTime(2025, 4, 20),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Sports", "Psychological", "Drama"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 260,
        chapterProgress: 260,
        lastChapterRead: 2,
        isStarred: false,
        isPending: true,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Solo Leveling",
        author: "Chugong",
        sinopsis: "El cazador más débil se convierte en el más fuerte.",
        rating: 4.8,
        startPublicationDate: DateTime(2018, 3, 4),
        nextPublicationDate: DateTime(2021, 12, 29),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Fantasy", "RPG"],
        status: MangaStatus.completed,
        totalChaptersAmount: 179,
        chapterProgress: 179,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
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
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Action", "Supernatural", "Comedy"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 107,
        chapterProgress: 107,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Black Clover",
        author: "Yūki Tabata",
        sinopsis: "Un chico sin magia lucha por ser el Rey Mago.",
        rating: 4.5,
        startPublicationDate: DateTime(2015, 2, 16),
        nextPublicationDate: DateTime(2025, 4, 21),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Magic", "Adventure", "Shonen"],
        status: MangaStatus.ongoing,
        totalChaptersAmount: 370,
        chapterProgress: 370,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Dr. Stone",
        author: "Riichiro Inagaki",
        sinopsis: "La humanidad revive tras miles de años petrificada.",
        rating: 4.6,
        startPublicationDate: DateTime(2017, 3, 6),
        nextPublicationDate: DateTime(2022, 3, 7),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Science", "Adventure", "Shonen"],
        status: MangaStatus.completed,
        totalChaptersAmount: 232,
        chapterProgress: 232,
        lastChapterRead: 2,
        isStarred: false,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),

      Manga(
        title: "Bakuman",
        author: "Tsugumi Ohba",
        sinopsis: "Dos jóvenes sueñan con ser mangakas exitosos.",
        rating: 4.7,
        startPublicationDate: DateTime(2008, 8, 11),
        nextPublicationDate: DateTime(2012, 4, 23),
        lastReadDate: DateTime(2025, 5, 1),
        genres: ["Drama", "Slice of Life", "Shonen"],
        status: MangaStatus.completed,
        totalChaptersAmount: 176,
        chapterProgress: 176,
        lastChapterRead: 2,
        isStarred: true,
        isPending: false,
        filePath: await getValidfilePath("Chainsaw Man 200.cbz"),
      ),
    ];
    view.updateMangaList(_allMangas);
  }

  void showAll() {
    filtered = _allMangas;
    view.updateMangaList(_allMangas);
  }

  @override
  void filterByStatus(List<MangaStatus> statusList) {
    filtered = _allMangas.where((m) => statusList.contains(m.status)).toList();
    view.updateMangaList(filtered);
  }

  @override
  void filterByGenres(List<String> genres) {
    filtered =
        _allMangas
            .where((m) => m.genres.any((g) => genres.contains(g)))
            .toList();
    view.updateMangaList(filtered);
  }

  void filterMangasByTitle(String query) {
    filtered =
        _allMangas.where((manga) {
          return manga.title.toLowerCase().contains(query.toLowerCase()) ||
              manga.author.toLowerCase().contains(query.toLowerCase());
        }).toList();
    if (filtered.isEmpty) {
      filtered = _allMangas;
    } else {
      view.updateMangaList(filtered);
    }
  }

  @override
  void sortBy(int criteria) {
    List<Manga> sorted = [..._allMangas];
    if (filtered.isNotEmpty) {
      sorted = [...filtered];
    }
    switch (criteria) {
      case 0: //Alphabetically
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 1: //Total Chapters / Chapters
        sorted.sort(
          (a, b) => b.totalChaptersAmount.compareTo(a.chapterProgress),
        );
        break;
      case 2: //Total Chapters / Chapters
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      // add more criteria
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
