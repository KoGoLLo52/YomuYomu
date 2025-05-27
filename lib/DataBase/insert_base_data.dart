import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:yomuyomu/Account/helpers/user_session_helper.dart';
import 'package:yomuyomu/DataBase/database_helper.dart';

Future<void> insertBaseData() async {
  final db = DatabaseHelper();
  final uuid = Uuid();

  final firebaseUser = FirebaseAuth.instance.currentUser;
  final String userId = await UserSession.getStoredUserId(); 
  final String email = firebaseUser?.email ?? 'local@example.com';
  final String username = firebaseUser?.displayName ?? 'local_user';

  final existingUser = await db.getUserById(userId);
  if (existingUser == null) {
    await db.insertUser({
      'UserID': userId,
      'Email': email,
      'Username': username,
      'Icon': null,
      'CreationDate': DateTime.now().millisecondsSinceEpoch,
      'SyncStatus': 0,
    });
    print('✅ Usuario insertado con el id $userId');
  }

  // Autor por defecto
  final unknownAuthor = await db.getAuthorById('unknown');
  if (unknownAuthor == null) {
    await db.insertAuthor({
      'AuthorID': 'unknown',
      'Name': 'unknown',
      'Biography': 'unknown',
      'Icon': null,
      'BirthDate': DateTime(1980, 1, 1).millisecondsSinceEpoch,
    });
  }

  // Géneros predeterminados
  final existingGenres = await db.getAllGenres();
  if (existingGenres.isEmpty) {
    const genres = [
      'Action', 'Adventure', 'Comedy', 'Drama', 'Ecchi', 'Fantasy', 'Horror',
      'Isekai', 'Josei', 'Martial Arts', 'Mecha', 'Music', 'Mystery',
      'Psychological', 'Romance', 'School', 'Sci-Fi', 'Seinen', 'Shoujo',
      'Shoujo Ai', 'Shounen', 'Shounen Ai', 'Slice of Life', 'Sports',
      'Supernatural', 'Thriller', 'Tragedy', 'Yaoi', 'Yuri', 'Historical',
      'Dementia', 'Parody', 'Magic', 'Military', 'Demons', 'Gangster', 'Game',
      'Survival', 'Samurai',
    ];

    for (var genre in genres.toSet()) {
      final genreId = uuid.v4();
      await db.insertGenre({'GenreID': genreId, 'Description': genre});
    }
  }

  // Configuración de usuario
  final settings = await db.getUserSettingsById(userId);
  if (settings == null) {
    await db.insertUserSettings({
      'UserID': userId,
      'Language': 1,
      'Theme': 0,
      'Orientation': 0,
      'SyncStatus': 0,
    });
    print('✅ UserSettings insertado con el id $userId');
  }
}
