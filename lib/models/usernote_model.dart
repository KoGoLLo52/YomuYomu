class UserNote {
  final String userId;
  final String mangaId;
  String? personalComment;
  double? personalRating;
  bool isFavorited;
  bool isPending;
  DateTime? lastEdited;
  int syncStatus;

  UserNote({
    required this.userId,
    required this.mangaId,
    this.personalComment,
    this.personalRating,
    this.isFavorited = false,
    this.isPending = false,
    this.lastEdited,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userId,
      'MangaID': mangaId,
      'PersonalComment': personalComment,
      'PersonalRating': personalRating,
      'IsFavorited': isFavorited ? 1 : 0,
      'IsPending': isPending ? 1 : 0,
      'LastEdited': lastEdited?.millisecondsSinceEpoch,
      'SyncStatus': syncStatus,
    };
  }

  factory UserNote.fromMap(Map<String, dynamic> map) {
    return UserNote(
      userId: map['UserID'],
      mangaId: map['MangaID'],
      personalComment: map['PersonalComment'],
      personalRating:
          map['PersonalRating'] != null
              ? (map['PersonalRating'] as num).toDouble()
              : null,
      isFavorited: map['IsFavorited'] == 1,
      isPending: map['IsPending'] == 1,
      lastEdited:
          map['LastEdited'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['LastEdited'])
              : null,
      syncStatus: map['SyncStatus'] ?? 0,
    );
  }
}
