import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:yomuyomu/contracts/manga_detail_contract.dart';
import 'package:yomuyomu/models/manga.dart';

class MangaDetailPresenter {
  final MangaDetailViewContract _view;
  late Manga _manga;

  MangaDetailPresenter(this._view);

  Future<void> loadMangaDetail() async {
    // Simulado: normalmente cargarías desde archivo o red
    _manga = Manga(
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
      chapters: [
        Chapter(
          number: 1,
          title: "Stone World",
          date: "2017-03-06",
          thumbnailUrl: "https://example.com/chapter1.jpg",
          coverUrl: '',
        ),
        Chapter(
          number: 2,
          title: "King of the Stone World",
          date: "2017-03-13",
          thumbnailUrl: "https://example.com/chapter2.jpg",
          coverUrl: '',
        ),
        Chapter(
          number: 3,
          title: "Weapons of Science",
          date: "2017-03-20",
          thumbnailUrl: "https://example.com/chapter3.jpg",
          coverUrl: '',
        ),
      ],
    );

    _view.showManga(_manga);
    _view.showChapters(_manga!.chapters ?? []);
  }

  void searchChapter(String query) {
    final results =
        (_manga.chapters ?? [])
            .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
    _view.showChapters(results);
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
