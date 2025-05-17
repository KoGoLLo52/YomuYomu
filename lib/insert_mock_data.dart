import 'package:uuid/uuid.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> insertSampleData() async {
  final db = DatabaseHelper();
  final uuid = Uuid();
  final prefs = await SharedPreferences.getInstance();

  // 1. Insertar usuario
  final userId = uuid.v4();
  prefs.setString('userId', userId);
  await db.insertUser({
    'UserID': userId,
    'Email': 'test@example.com',
    'Username': 'usuario_prueba',
    'Icon': null,
    'CreationDate': DateTime.now().millisecondsSinceEpoch,
    'SyncStatus': 0,
  });

  // 2. Insertar autor
  final authorId = uuid.v4();
  await db.insertAuthor({
    'AuthorID': authorId,
    'Name': 'Autor X',
    'Biography': 'Un autor ficticio para pruebas.',
    'Icon': null,
    'BirthDate': DateTime(1980, 1, 1).millisecondsSinceEpoch,
  });

  // 3. Insertar carpeta de usuario
  final folderId = uuid.v4();
  await db.insertUserLibraryStructure({
    'FolderID': folderId,
    'UserID': userId,
    'FolderName': 'Favoritos',
    'Description': 'Mis mangas favoritos',
    'ParentFolderID': null,
    'SyncStatus': 0,
  });

  // 4. Insertar manga
  final mangaId = uuid.v4();
  await db.insertManga({
    'MangaID': mangaId,
    'AuthorID': authorId,
    'Title': 'Manga de Prueba',
    'Sinopsis': 'Una historia interesante.',
    'Rating': 4.5,
    'StartPublicationDate': DateTime(2020, 1, 1).millisecondsSinceEpoch,
    'NextPublicationDate': null,
    'Chapters': 3,
    'SyncStatus': 0,
  });

  // 5. Relación carpeta-manga
  await db.insertFolderManga({
    'FolderID': folderId,
    'MangaID': mangaId,
    'SyncStatus': 0,
  });

  // 6. Insertar capítulos
  for (int i = 1; i <= 3; i++) {
    await db.insertChapter({
      'ChapterID': uuid.v4(),
      'MangaID': mangaId,
      'ChapterNumber': i,
      'PanelsCount': 10 + i,
      'Title': 'Capítulo $i',
      'Synopsis': 'Resumen del capítulo $i',
      'CoverImage': 'https://example.com/chapter$i.jpg',
      'PublicationDate': DateTime(2020, 1, i).millisecondsSinceEpoch,
      'SyncStatus': 0,
    });
  }

  // 7. Insertar géneros
  const genres = ['Acción', 'Aventura'];
  for (var genre in genres) {
    final genreId = uuid.v4();
    await db.insertGenre({'GenreID': genreId, 'Description': genre});
    await db.insertGenreManga({
      'MangaID': mangaId,
      'GenreID': genreId,
    });
  }

  // 8. Insertar ajustes de usuario
  await db.insertUserSettings({
    'UserID': userId,
    'Language': 1,
    'Theme': 0,
    'Orientation': 0,
    'SyncStatus': 0,
  });

  // 9. Insertar nota de usuario sobre el manga
  await db.insertUserNote({
    'UserID': userId,
    'MangaID': mangaId,
    'PersonalComment': '¡Muy buen manga!',
    'PersonalRating': 4.8,
    'IsFavorited': 1,
    'IsPending': 0,
    'LastEdited': DateTime.now().millisecondsSinceEpoch,
    'SyncStatus': 0,
  });

  print('✅ Datos de prueba insertados correctamente.');
}
