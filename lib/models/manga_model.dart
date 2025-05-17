import 'package:yomuyomu/models/chapter_model.dart';

class Manga {
  final String id;
  String title;
  String authorId;
  String? synopsis;
  double rating;
  DateTime startPublicationDate;
  DateTime? nextPublicationDate;
  DateTime? lastReadDate;
  List<String> genres;
  MangaStatus status;
  int totalChaptersAmount;
  int chapterProgress;
  int lastChapterRead;
  bool isStarred;
  bool isPending;
  String? coverUrl;
  String? folderId;
  List<Chapter>? chapters;

  Manga({
    required this.id,
    required this.title,
    required this.authorId,
    this.synopsis,
    this.rating = 0.0,
    required this.startPublicationDate,
    this.nextPublicationDate,
    this.lastReadDate,
    this.genres = const [],
    this.status = MangaStatus.ongoing,
    required this.totalChaptersAmount,
    this.chapterProgress = 0,
    this.lastChapterRead = 0,
    this.isStarred = false,
    this.isPending = false,
    this.coverUrl,
    this.folderId,
    this.chapters,
  }) {
    // Validaciones
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5');
    }
    if (nextPublicationDate != null &&
        nextPublicationDate!.isBefore(startPublicationDate)) {
      throw ArgumentError('Next publication date must be after start date');
    }
    if (lastReadDate != null && lastReadDate!.isBefore(startPublicationDate)) {
      throw ArgumentError('Last read date cannot be before start date');
    }
  }

  Map<String, dynamic> toMap() => {
    'MangaID': id,
    'AuthorID': authorId,
    'Title': title,
    'synopsis': synopsis,
    'Rating': rating,
    'StartPublicationDate': startPublicationDate.millisecondsSinceEpoch,
    'NextPublicationDate': nextPublicationDate?.millisecondsSinceEpoch,
    'Chapters': totalChaptersAmount,
  };

  factory Manga.fromMap(Map<String, dynamic> map) {
    return Manga(
      id: map['MangaID'] ?? '',
      authorId: map['AuthorID'],
      title: map['Title'] ?? '',
      synopsis: map['Sinopsis'],
      rating: map['Rating'] != null ? (map['Rating'] as num).toDouble() : 0,
      startPublicationDate:
          map['StartPublicationDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['StartPublicationDate'])
              : DateTime.now(),
      nextPublicationDate:
          map['NextPublicationDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['NextPublicationDate'])
              : DateTime.now(),
      totalChaptersAmount: map['Chapters'] ?? 0,
      // Otros campos como chapterProgress, lastChapterRead, isStarred... si están en memoria o se agregan luego
    );
  }
}

enum MangaStatus {
  ongoing(0),
  completed(1),
  hiatus(2),
  cancelled(3);

  final int value;
  const MangaStatus(this.value);

  static MangaStatus fromInt(int value) {
    return MangaStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MangaStatus.ongoing,
    );
  }

  int toInt() => value;
}
