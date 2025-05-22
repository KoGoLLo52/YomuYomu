class SettingsModel {
  final String userID;
  final int language;
  final int theme;
  final int orientation;
  final int syncStatus;

  SettingsModel({
    required this.userID,
    this.language = 0,
    this.theme = 0,
    this.orientation = 0,
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'Language': language,
      'Theme': theme,
      'Orientation': orientation,
      'SyncStatus': syncStatus,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      userID: map['UserID'],
      language: map['Language'] ?? 0,
      theme: map['Theme'] ?? 0,
      orientation: map['Orientation'] ?? 0,
      syncStatus: map['SyncStatus'] ?? 0,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();
}
