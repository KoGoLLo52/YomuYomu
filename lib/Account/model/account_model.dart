class AccountModel {
  final String userID;
  final String email;
  final String username;
  final DateTime creationDate;
  final String? icon;
  final int syncStatus;

  final String mostReadGenre;
  final String mostReadAuthor;
  final List<Uri> favoriteMangaCovers;
  final int finishedMangasCount;
  final int commentsPosted;

  AccountModel({
    required this.userID,
    required this.email,
    required this.username,
    required this.creationDate,
    this.icon,
    this.syncStatus = 0,
    this.mostReadGenre = '',
    this.mostReadAuthor = '',
    this.favoriteMangaCovers = const [],
    this.finishedMangasCount = 0,
    this.commentsPosted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'Email': email,
      'Username': username,
      'Icon': icon,
      'CreationDate': creationDate.millisecondsSinceEpoch,
      'SyncStatus': syncStatus,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      userID: map['UserID'],
      email: map['Email'],
      username: map['Username'],
      icon: map['Icon'],
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['CreationDate']),
      syncStatus: map['SyncStatus'] ?? 0,
    );
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();
}
