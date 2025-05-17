class AccountModel {
  final String userID;
  final String username;
  final DateTime creationDate;
  final String mostReadGenre;
  final String mostReadAuthor;
  final List<Uri> favoriteMangaCovers;
  final int finishedMangasCount;
  final int commentsPosted;

  AccountModel({
    required this.userID,
    required this.username,
    required this.creationDate,
    required this.mostReadGenre,
    required this.mostReadAuthor,
    required this.favoriteMangaCovers,
    required this.finishedMangasCount,
    required this.commentsPosted,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      userID: map['UserID'],
      username: map['Username'],
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['CreationDate']),
      mostReadGenre: map['MostReadGenre'],
      mostReadAuthor: map['MostReadAuthor'],
      favoriteMangaCovers: (map['FavoriteMangaCovers'] as List<dynamic>?)
              ?.map((e) => Uri.parse(e.toString()))
              .toList() ??
          [],
      finishedMangasCount: map['FinishedMangasCount'] ?? 0,
      commentsPosted: map['CommentsPosted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'Username': username,
      'CreationDate': creationDate.millisecondsSinceEpoch,
      'MostReadGenre': mostReadGenre,
      'MostReadAuthor': mostReadAuthor,
      'FavoriteMangaCovers': favoriteMangaCovers.map((e) => e.toString()).toList(),
      'FinishedMangasCount': finishedMangasCount,
      'CommentsPosted': commentsPosted,
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
