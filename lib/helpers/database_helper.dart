import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yomuyomu/models/manga_model.dart';

class DatabaseHelper {
  static const _databaseName = "yomuyomu.db";
  static const _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await db.execute('PRAGMA foreign_keys = ON;');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS User (
        UserID TEXT PRIMARY KEY,
        Email TEXT NOT NULL,
        Username TEXT NOT NULL,
        Icon TEXT,
        CreationDate INTEGER NOT NULL,
        SyncStatus INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Author (
        AuthorID TEXT PRIMARY KEY,
        Name TEXT NOT NULL,
        Biography TEXT,
        Icon TEXT,
        BirthDate INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Manga (
        MangaID TEXT PRIMARY KEY,
        AuthorID TEXT,
        Title TEXT NOT NULL,
        Sinopsis TEXT,
        Rating REAL,
        CoverImage TEXT,
        StartPublicationDate INTEGER NOT NULL,
        NextPublicationDate INTEGER,
        Chapters INTEGER NOT NULL,
        SyncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Chapter (
        ChapterID TEXT PRIMARY KEY,
        MangaID TEXT NOT NULL,
        ChapterNumber INTEGER NOT NULL,
        PanelsCount INTEGER NOT NULL,
        Title TEXT,
        Synopsis TEXT,
        CoverImage TEXT,
        PublicationDate INTEGER,
        SyncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (MangaID) REFERENCES Manga(MangaID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Panel (
        PanelID TEXT PRIMARY KEY,
        ChapterID TEXT NOT NULL,
        ImagePath TEXT NOT NULL,
        PageNumber INTEGER NOT NULL,
        SyncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (ChapterID) REFERENCES Chapter(ChapterID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Genre (
        GenreID TEXT PRIMARY KEY,
        Description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS GenreManga (
        MangaID TEXT,
        GenreID TEXT,
        PRIMARY KEY (MangaID, GenreID),
        FOREIGN KEY (MangaID) REFERENCES Manga(MangaID),
        FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Comment (
        CommentID TEXT PRIMARY KEY,
        MangaID TEXT NOT NULL,
        UserID TEXT NOT NULL,
        Content TEXT NOT NULL,
        Likes INTEGER DEFAULT 0,
        Dislikes INTEGER DEFAULT 0,
        FOREIGN KEY (MangaID) REFERENCES Manga(MangaID),
        FOREIGN KEY (UserID) REFERENCES User(UserID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS UserProgress (
        UserID TEXT,
        PanelID TEXT,
        LastReadDate INTEGER,
        SyncStatus INTEGER DEFAULT 0,
        PRIMARY KEY (UserID),
        FOREIGN KEY (UserID) REFERENCES User(UserID),
        FOREIGN KEY (PanelID) REFERENCES Panel(PanelID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS UserNote (
        UserID TEXT,
        MangaID TEXT,
        PersonalComment TEXT,
        PersonalRating REAL,
        IsFavorited INTEGER DEFAULT 0,
        IsPending INTEGER DEFAULT 0,
        LastEdited INTEGER,
        SyncStatus INTEGER DEFAULT 0,
        PRIMARY KEY (UserID, MangaID),
        FOREIGN KEY (UserID) REFERENCES User(UserID),
        FOREIGN KEY (MangaID) REFERENCES Manga(MangaID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS UserSettings (
        UserID TEXT PRIMARY KEY,
        Language INTEGER DEFAULT 0,
        Theme INTEGER DEFAULT 0,
        Orientation INTEGER DEFAULT 0,
        SyncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (UserID) REFERENCES User(UserID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS UserLibraryStructure (
        FolderID TEXT PRIMARY KEY,
        UserID TEXT NOT NULL,
        FolderName TEXT NOT NULL,
        Description TEXT,
        ParentFolderID TEXT,
        SyncStatus INTEGER DEFAULT 0,
        FOREIGN KEY (UserID) REFERENCES User(UserID),
        FOREIGN KEY (ParentFolderID) REFERENCES UserLibraryStructure(FolderID)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS FolderManga (
        FolderID TEXT,
        MangaID TEXT,
        SyncStatus INTEGER DEFAULT 0,
        PRIMARY KEY (FolderID, MangaID),
        FOREIGN KEY (FolderID) REFERENCES UserLibraryStructure(FolderID),
        FOREIGN KEY (MangaID) REFERENCES Manga(MangaID)
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Lógica de migración futura
    }
  }

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> queryById(
    String table,
    String key,
    String id,
  ) async {
    final db = await database;
    final result = await db.query(table, where: '$key = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String key,
    String id,
  ) async {
    final db = await database;
    return await db.update(table, data, where: '$key = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String key, String id) async {
    final db = await database;
    return await db.delete(table, where: '$key = ?', whereArgs: [id]);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  Future<int> insertUser(Map<String, dynamic> data) => insert('User', data);
  Future<List<Map<String, dynamic>>> getAllUsers() => queryAll('User');
  Future<Map<String, dynamic>?> getUserById(String id) =>
      queryById('User', 'UserID', id);
  Future<int> updateUser(Map<String, dynamic> data, String id) {
    final filteredData = Map<String, dynamic>.from(data)
      ..removeWhere((key, value) => value == null);

    return update('User', filteredData, 'UserID', id);
  }

  Future<int> deleteUser(String id) => delete('User', 'UserID', id);

  Future<int> insertAuthor(Map<String, dynamic> data) => insert('Author', data);
  Future<List<Map<String, dynamic>>> getAllAuthors() => queryAll('Author');
  Future<Map<String, dynamic>?> getAuthorById(String id) =>
      queryById('Author', 'AuthorID', id);
  Future<int> updateAuthor(Map<String, dynamic> data, String id) =>
      update('Author', data, 'AuthorID', id);
  Future<int> deleteAuthor(String id) => delete('Author', 'AuthorID', id);

  Future<int> insertComment(Map<String, dynamic> data) =>
      insert('Comment', data);
  Future<List<Map<String, dynamic>>> getAllComments() => queryAll('Comment');
  Future<Map<String, dynamic>?> getCommentById(String id) =>
      queryById('Comment', 'CommentID', id);
  Future<int> updateComment(Map<String, dynamic> data, String id) =>
      update('Comment', data, 'CommentID', id);
  Future<int> deleteComment(String id) => delete('Comment', 'CommentID', id);

  Future<int> insertManga(Map<String, dynamic> data) => insert('Manga', data);
  Future<List<Map<String, dynamic>>> getAllMangas() => queryAll('Manga');
  Future<Map<String, dynamic>?> getMangaById(String id) =>
      queryById('Manga', 'MangaID', id);
  Future<int> updateManga(Map<String, dynamic> data, String id) =>
      update('Manga', data, 'MangaID', id);
  Future<int> deleteManga(String id) => delete('Manga', 'MangaID', id);

  Future<int> insertChapter(Map<String, dynamic> data) =>
      insert('Chapter', data);
  Future<List<Map<String, dynamic>>> getAllChapters() => queryAll('Chapter');
  Future<Map<String, dynamic>?> getChapterById(String id) =>
      queryById('Chapter', 'ChapterID', id);
  Future<int> updateChapter(Map<String, dynamic> data, String id) =>
      update('Chapter', data, 'ChapterID', id);
  Future<int> deleteChapter(String id) => delete('Chapter', 'ChapterID', id);

  Future<int> insertPanel(Map<String, dynamic> data) => insert('Panel', data);
  Future<List<Map<String, dynamic>>> getAllPanels() => queryAll('Panel');
  Future<Map<String, dynamic>?> getPanelById(String id) =>
      queryById('Panel', 'PanelID', id);
  Future<int> updatePanel(Map<String, dynamic> data, String id) =>
      update('Panel', data, 'PanelID', id);
  Future<int> deletePanel(String id) => delete('Panel', 'PanelID', id);

  Future<int> insertGenre(Map<String, dynamic> data) => insert('Genre', data);
  Future<List<Map<String, dynamic>>> getAllGenres() => queryAll('Genre');
  Future<Map<String, dynamic>?> getGenreById(String id) =>
      queryById('Genre', 'GenreID', id);
  Future<int> updateGenre(Map<String, dynamic> data, String id) =>
      update('Genre', data, 'GenreID', id);
  Future<int> deleteGenre(String id) => delete('Genre', 'GenreID', id);

  Future<int> insertGenreManga(Map<String, dynamic> data) =>
      insert('GenreManga', data);
  Future<List<Map<String, dynamic>>> getAllGenreManga() =>
      queryAll('GenreManga');

  Future<int> insertUserProgress(Map<String, dynamic> data) =>
      insert('UserProgress', data);
  Future<List<Map<String, dynamic>>> getAllUserProgress() =>
      queryAll('UserProgress');
  Future<Map<String, dynamic>?> getUserProgressById(String id) =>
      queryById('UserProgress', 'UserID', id);
  Future<int> updateUserProgress(Map<String, dynamic> data, String id) =>
      update('UserProgress', data, 'UserID', id);
  Future<int> deleteUserProgress(String id) =>
      delete('UserProgress', 'UserID', id);

  Future<int> insertUserNote(Map<String, dynamic> data) =>
      insert('UserNote', data);
  Future<List<Map<String, dynamic>>> getAllUserNotes() => queryAll('UserNote');

  Future<int> insertUserSettings(Map<String, dynamic> data) =>
      insert('UserSettings', data);
  Future<List<Map<String, dynamic>>> getAllUserSettings() =>
      queryAll('UserSettings');
  Future<Map<String, dynamic>?> getUserSettingsById(String id) =>
      queryById('UserSettings', 'UserID', id);
  Future<int> updateUserSettings(Map<String, dynamic> data, String id) =>
      update('UserSettings', data, 'UserID', id);
  Future<int> deleteUserSettings(String id) =>
      delete('UserSettings', 'UserID', id);

  Future<int> insertUserLibraryStructure(Map<String, dynamic> data) =>
      insert('UserLibraryStructure', data);
  Future<List<Map<String, dynamic>>> getAllUserLibraryStructures() =>
      queryAll('UserLibraryStructure');
  Future<Map<String, dynamic>?> getUserLibraryStructureById(String id) =>
      queryById('UserLibraryStructure', 'FolderID', id);
  Future<int> updateUserLibraryStructure(
    Map<String, dynamic> data,
    String id,
  ) => update('UserLibraryStructure', data, 'FolderID', id);
  Future<int> deleteUserLibraryStructure(String id) =>
      delete('UserLibraryStructure', 'FolderID', id);

  Future<int> insertFolderManga(Map<String, dynamic> data) =>
      insert('FolderManga', data);
  Future<List<Map<String, dynamic>>> getAllFolderManga() =>
      queryAll('FolderManga');

  Future<List<Map<String, dynamic>>> getChaptersByMangaId(
    String mangaId,
  ) async {
    final db = await database;
    return await db.query(
      'Chapter',
      where: 'MangaID = ?',
      whereArgs: [mangaId],
      orderBy: 'ChapterNumber ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getPanelsByChapterId(
    String chapterId,
  ) async {
    final db = await database;
    return await db.query(
      'Panel',
      where: 'ChapterID = ?',
      whereArgs: [chapterId],
    );
  }

  Future<void> updateMangaCover(String mangaId, String coverUrl) async {
    final db = await database;
    await db.update(
      'Manga',
      {'CoverImage': coverUrl},
      where: 'MangaID = ?',
      whereArgs: [mangaId],
    );
  }

  Future<void> updateMangaChapterCount(
    String mangaId,
    int chapterCountToAdd,
  ) async {
    final db = await database;

    final result = await db.query(
      'Manga',
      columns: ['Chapters'],
      where: 'MangaID = ?',
      whereArgs: [mangaId],
    );

    if (result.isNotEmpty) {
      final currentCount = result.first['Chapters'] as int;
      final newCount = currentCount + chapterCountToAdd;

      await db.update(
        'Manga',
        {'Chapters': newCount},
        where: 'MangaID = ?',
        whereArgs: [mangaId],
      );
    } else {
      throw Exception("Manga con ID $mangaId no encontrado.");
    }
  }

  Future<List<Map<String, dynamic>>> getUserLibrary(String userId) async {
    final db = await database;
    return await db.query(
      'UserLibraryStructure',
      where: 'UserID = ?',
      whereArgs: [userId],
      orderBy: 'FolderName ASC',
    );
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else {
      openAppSettings();
      return false;
    }
  }

  Future<Manga?> getMangaByTitle(String title) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'Manga',
      where: 'title = ?',
      whereArgs: [title],
    );

    if (maps.isNotEmpty) {
      return Manga.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Manga>> getAllMangaByUserId(String userId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT M.*
    FROM Manga M
    INNER JOIN FolderManga FM ON M.MangaID = FM.MangaID
    INNER JOIN UserLibraryStructure ULS ON FM.FolderID = ULS.FolderID
    WHERE ULS.UserID = ?
    ORDER BY M.Title COLLATE NOCASE ASC;
  ''',
      [userId],
    );

    return maps
        .map((map) {
          try {
            return Manga.fromMap(map);
          } catch (e) {
            print('❌ Error al convertir manga: $map\n$e');
            return null;
          }
        })
        .whereType<Manga>()
        .toList();
  }

  Future<Map<String, dynamic>?> getLastReadPanelForManga({
    required String userId,
    required String mangaId,
  }) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT
      up.PanelID,
      p.ChapterID,
      c.ChapterNumber,
      p.PageNumber,
      up.LastReadDate
    FROM UserProgress up
    JOIN Panel p ON up.PanelID = p.PanelID
    JOIN Chapter c ON p.ChapterID = c.ChapterID
    WHERE up.UserID = ?
      AND c.MangaID = ?
    ORDER BY up.LastReadDate DESC
    LIMIT 1;
  ''',
      [userId, mangaId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'User',
      where: 'Email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
