class Manga {
  String _title;
  String _author;
  String _sinopsis;
  double _rating;
  DateTime _startPublicationDate;
  DateTime _nextPublicationDate;
  DateTime _lastReadDate;
  List<String> _genres;
  MangaStatus _status;
  int _totalChaptersAmount;
  int _chapterProgress;
  bool _isStarred;
  bool _isPending;
  String _filePath;
  String? folder;

  Manga({
    required String title,
    required String author,
    required String sinopsis,
    required double rating,
    required DateTime startPublicationDate,
    required DateTime nextPublicationDate,
    required DateTime lastReadDate,
    required List<String> genres,
    required MangaStatus status,
    required int totalChaptersAmount,
    required int chapterProgress,
    required bool isStarred,
    required bool isPending,
    required String filePath,
    this.folder,
  }) : _title = title,
       _author = author,
       _sinopsis = sinopsis,
       _rating = rating,
       _startPublicationDate = startPublicationDate,
       _nextPublicationDate = nextPublicationDate,
       _lastReadDate = lastReadDate,
       _genres = genres,
       _status = status,
       _totalChaptersAmount = totalChaptersAmount,
       _chapterProgress = chapterProgress,
       _isStarred = isStarred,
       _isPending = isPending,
       _filePath = filePath;

  // Getters y Setters
  String get title => _title;
  set title(String value) => _title = value;

  String get author => _author;
  set author(String value) => _author = value;

  String get sinopsis => _sinopsis;
  set sinopsis(String value) => _sinopsis = value;

  double get rating => _rating;
  set rating(double value) {
    if (value >= 0 && value <= 5) {
      _rating = value;
    } else {
      throw ArgumentError('Rating must be between 0 and 5');
    }
  }

  DateTime get startPublicationDate => _startPublicationDate;
  set startPublicationDate(DateTime value) => _startPublicationDate = value;

  DateTime get nextPublicationDate => _nextPublicationDate;
  set nextPublicationDate(DateTime value) {
    if (value.isAfter(startPublicationDate)) {
      _nextPublicationDate = value;
    } else {
      throw ArgumentError(
        'Next publication date must be after the startPublicationDate',
      );
    }
  }

  DateTime get lastReadDate => _lastReadDate;
  set lastReadDate(DateTime value) {
    if (value.isAfter(startPublicationDate)) {
      _lastReadDate = value;
    } else {
      throw ArgumentError(
        'LastReadDate cant be before the startPublicationDate',
      );
    }
  }

  List<String> get genres => _genres;
  set genres(List<String> value) => _genres = value;

  MangaStatus get status => _status;
  set status(MangaStatus value) => _status = value;

  int get statusAsInt => _status.toInt();

  int get totalChaptersAmount => _totalChaptersAmount;
  set totalChaptersAmount(int value) => _totalChaptersAmount = value;

  int get chapterProgress => _chapterProgress;
  set chapterProgress(int value) => _chapterProgress = value;

  bool get isStarred => _isStarred;
  set isStarred(bool value) => _isStarred = value;

  bool get isPending => _isPending;
  set isPending(bool value) => _isPending = value;

  String get filePath => _filePath;
  set filePath(String value) => _filePath = value;
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
      orElse: () => MangaStatus.ongoing, // valor por defecto
    );
  }

  int toInt() => value;
}
