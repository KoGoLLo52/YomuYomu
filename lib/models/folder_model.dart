import 'package:yomuyomu/models/manga_model.dart';

class FolderModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? parentFolderId;
  final List<Manga> mangas;
  final List<FolderModel> subfolders;
  final int syncStatus;

  FolderModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.parentFolderId,
    this.mangas = const [],
    this.subfolders = const [],
    this.syncStatus = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'FolderID': id,
      'UserID': userId,
      'FolderName': name,
      'Description': description,
      'ParentFolderID': parentFolderId,
      'SyncStatus': syncStatus,
    };
  }
  
  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['FolderID'],
      userId: map['UserID'],
      name: map['FolderName'],
      description: map['Description'],
      parentFolderId: map['ParentFolderID'],
      // mangas y subfolders se gestionan externamente mediante joins
      syncStatus: map['SyncStatus'] ?? 0,
    );
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) => FolderModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  FolderModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? parentFolderId,
    List<Manga>? mangas,
    List<FolderModel>? subfolders,
    int? syncStatus,
  }) {
    return FolderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      mangas: mangas ?? this.mangas,
      subfolders: subfolders ?? this.subfolders,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
