
class Manga {
  String title;
  String author;
  String sinopsis;
  double rating;
  DateTime startPublicationDate;
  DateTime nextPublicationDate;
  List<String> genres;
  String status;
  int chapterProgress;
  bool isStarred;
  String filePath;

  Manga({
    required this.title,
    required this.author,
    required this.sinopsis,
    required this.rating,
    required this.startPublicationDate,
    required this.nextPublicationDate,
    required this.genres,
    required this.status,
    required this.chapterProgress,
    required this.isStarred,
    required this.filePath,
  });
}
