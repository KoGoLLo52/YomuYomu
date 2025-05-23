import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> insertSampleData() async {
  final db = DatabaseHelper();
  final uuid = Uuid();
  final prefs = await SharedPreferences.getInstance();
  String userId = uuid.v4();
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    userId = currentUser.uid;
  }
  // 1. Insertar usuario
  prefs.setString('userId', userId);
  await db.insertUser({
    'UserID': userId,
    'Email': 'test@example.com',
    'Username': 'usuario_prueba',
    'Icon': null,
    'CreationDate': DateTime.now().millisecondsSinceEpoch,
    'SyncStatus': 0,
  });
  //1.1 Usuario local
  await db.insertUser({
    'UserID': 'local',
    'Email': 'local@example.com',
    'Username': 'local',
    'Icon': null,
    'CreationDate': DateTime.now().millisecondsSinceEpoch,
    'SyncStatus': 0,
  });

  // 2. Insertar autor
  final authorId = uuid.v4();
  await db.insertAuthor({
    'AuthorID': authorId,
    'Name': 'PEpe',
    'Biography': 'Un autor ficticio para pruebas.',
    'Icon': null,
    'BirthDate': DateTime(1980, 1, 1).millisecondsSinceEpoch,
  });

  await db.insertAuthor({
    'AuthorID': 'unknown',
    'Name': 'unknown',
    'Biography': 'Un autor ficticio para pruebas.',
    'Icon': null,
    'BirthDate': DateTime(1980, 1, 1).millisecondsSinceEpoch,
  });

  // 4. Insertar manga
  final mangaId = uuid.v4();
  await db.insertManga({
    'MangaID': mangaId,
    'AuthorID': authorId,
    'Title': 'Manga de Prueba',
    'Synopsis': 'Una historia interesante.',
    'Rating': 4.5,
    'StartPublicationDate': DateTime(2020, 1, 1).millisecondsSinceEpoch,
    'NextPublicationDate': null,
    'Chapters': 3,
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
  const genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Ecchi',
    'Fantasy',
    'Horror',
    'Isekai',
    'Josei',
    'Martial Arts',
    'Mecha',
    'Music',
    'Mystery',
    'Psychological',
    'Romance',
    'School',
    'Sci-Fi',
    'Seinen',
    'Shoujo',
    'Shoujo Ai',
    'Shounen',
    'Shounen Ai',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Thriller',
    'Tragedy',
    'Yaoi',
    'Yuri',
    'Historical',
    'Dementia',
    'Parody',
    'Magic',
    'Military',
    'Demons',
    'Gangster',
    'Game',
    'Survival',
    'Martial Arts',
    'Samurai',
  ];

  for (var genre in genres) {
    final genreId = uuid.v4();
    await db.insertGenre({'GenreID': genreId, 'Description': genre});
  }

  // 8. Insertar ajustes de usuario
  await db.insertUserSettings({
    'UserID': userId,
    'Language': 1,
    'Theme': 0,
    'Orientation': 0,
    'SyncStatus': 0,
  });

  print('✅ Datos de prueba insertados correctamente.');
}
