class Chapter {
  final String id;
  final String mangaId;
  final int chapterNumber;
  final int panelsCount;
  final String filePath;
  final String? title;
  final String? synopsis;
  final String? coverUrl;
  final DateTime? publicationDate;

  Chapter({
    required this.id,
    required this.mangaId,
    required this.chapterNumber,
    required this.panelsCount,
    required this.filePath,
    this.title,
    this.synopsis,
    this.coverUrl,
    this.publicationDate,
  });

  Map<String, dynamic> toMap() => {
    'ChapterID': id,
    'MangaID': mangaId,
    'ChapterNumber': chapterNumber,
    'PanelsCount': panelsCount,
    'Title': title,
    'Synopsis': synopsis,
    'CoverImage': coverUrl,
    'PublicationDate': publicationDate?.millisecondsSinceEpoch,
  };

  static Chapter fromMap(Map<String, dynamic> map) => Chapter(
    id: map['ChapterID'],
    mangaId: map['MangaID'],
    chapterNumber: map['ChapterNumber'],
    panelsCount: map['PanelsCount'],
    title: map['Title'],
    synopsis: map['Synopsis'],
    coverUrl: map['CoverImage'],
    publicationDate:
        map['PublicationDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['PublicationDate'])
            : null,
    filePath: '',
  );
}
