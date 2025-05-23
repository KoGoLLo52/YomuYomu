import 'package:yomuyomu/models/chapter_model.dart';

class MangaModel {
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

  MangaModel({
    required this.id,
    required this.title,
    required this.authorId,
    this.synopsis,
    this.rating = 0.0,
    required this.startPublicationDate,
    this.nextPublicationDate,
    this.lastReadDate,
    List<String>? genres,
    this.status = MangaStatus.ongoing,
    required this.totalChaptersAmount,
    this.chapterProgress = 0,
    this.lastChapterRead = 0,
    this.isStarred = false,
    this.isPending = false,
    this.coverUrl,
    this.folderId,
    this.chapters,
  }) : genres = (genres ?? []) {
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
        'Synopsis': synopsis,
        'Rating': rating,
        'StartPublicationDate': startPublicationDate.millisecondsSinceEpoch,
        'NextPublicationDate': nextPublicationDate?.millisecondsSinceEpoch,
        'Chapters': totalChaptersAmount,
        'CoverImage': coverUrl,
      };

  factory MangaModel.fromMap(Map<String, dynamic> map, {List<String> genres = const []}) {
    return MangaModel(
      id: map['MangaID'] ?? '',
      authorId: map['AuthorID'],
      title: map['Title'] ?? '',
      synopsis: map['Synopsis'],
      rating: map['Rating'] != null ? (map['Rating'] as num).toDouble() : 0,
      startPublicationDate: map['StartPublicationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['StartPublicationDate'])
          : DateTime.now(),
      nextPublicationDate: map['NextPublicationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['NextPublicationDate'])
          : null,
      totalChaptersAmount: map['Chapters'] ?? 0,
      coverUrl: map['CoverImage'],
      genres: genres,
    );
  }

  MangaModel copyWith({
    String? title,
    String? authorId,
    String? synopsis,
    double? rating,
    DateTime? startPublicationDate,
    DateTime? nextPublicationDate,
    DateTime? lastReadDate,
    List<String>? genres,
    MangaStatus? status,
    int? totalChaptersAmount,
    int? chapterProgress,
    int? lastChapterRead,
    bool? isStarred,
    bool? isPending,
    String? coverUrl,
    String? folderId,
    List<Chapter>? chapters,
  }) {
    return MangaModel(
      id: this.id,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      synopsis: synopsis ?? this.synopsis,
      rating: rating ?? this.rating,
      startPublicationDate: startPublicationDate ?? this.startPublicationDate,
      nextPublicationDate: nextPublicationDate ?? this.nextPublicationDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      totalChaptersAmount: totalChaptersAmount ?? this.totalChaptersAmount,
      chapterProgress: chapterProgress ?? this.chapterProgress,
      lastChapterRead: lastChapterRead ?? this.lastChapterRead,
      isStarred: isStarred ?? this.isStarred,
      isPending: isPending ?? this.isPending,
      coverUrl: coverUrl ?? this.coverUrl,
      folderId: folderId ?? this.folderId,
      chapters: chapters ?? this.chapters,
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
