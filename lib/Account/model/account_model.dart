class AccountModel {
  final String userID;
  final String email;
  final String username;
  final DateTime creationDate;
  final String? icon;
  final int syncStatus;

  final String mostReadGenre;
  final String mostReadAuthor;
  final List<String> favoriteMangaCovers;
  final int finishedMangasCount;

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

   Map<String, dynamic> toJson() => {
    'UserID': userID,
    'Email': email,
    'Username': username,
    'Icon': icon,
    'CreationDate': creationDate,
    'SyncStatus': syncStatus,
  };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    userID: json['UserID'],
    email: json['Email'],
    username: json['Username'],
    icon: json['Icon'],
    creationDate: json['CreationDate'],
    syncStatus: json['SyncStatus'] ?? 0,
  );
}
