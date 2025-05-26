// sync_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';

class SyncService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> syncUserTable() async {
    final db = await dbHelper.database;
    final users = await db.query('User', where: 'SyncStatus = 1');

    for (var user in users) {
      final userId = user['UserID'] as String;
      try {
        final email = user['Email'] as String;
        final username = user['Username'] as String;
        final icon = user['Icon'] as String?;
        final creationDateMillis = user['CreationDate'] as int;

        final creationDate = DateTime.fromMillisecondsSinceEpoch(
          creationDateMillis,
        );

        await firestore.collection('users').doc(userId).set({
          'UserID': userId,
          'Email': email,
          'Username': username,
          'Icon': icon,
          'CreationDate': creationDate.millisecondsSinceEpoch,
          'SyncStatus':
              0,
        }, SetOptions(merge: true));

        await db.update(
          'User',
          {'SyncStatus': 0},
          where: 'UserID = ?',
          whereArgs: [userId],
        );
      } catch (e, st) {
        print('❌ Error sincronizando usuario $userId: $e');
        print(st);
      }
    }
  }

  Future<void> syncAuthorTable() async {
    final db = await dbHelper.database;
    final authors = await db.query('Author');

    for (var author in authors) {
      final authorId = author['AuthorID'];
      try {
        await firestore.collection('authors').doc(authorId as String?).set({
          'name': author['Name'],
          'biography': author['Biography'],
          'icon': author['Icon'],
          'birthDate': author['BirthDate'],
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error sincronizando autor $authorId: $e');
      }
    }
  }

  Future<void> syncMangaTable() async {
    final db = await dbHelper.database;
    final mangas = await db.query('Manga', where: 'SyncStatus = 1');

    for (var manga in mangas) {
      final mangaId = manga['MangaID'];
      try {
        await firestore.collection('mangas').doc(mangaId as String?).set({
          'authorId': manga['AuthorID'],
          'title': manga['Title'],
          'sinopsis': manga['Sinopsis'],
          'rating': manga['Rating'],
          'startPublicationDate': manga['StartPublicationDate'],
          'nextPublicationDate': manga['NextPublicationDate'],
          'chapters': manga['Chapters'],
        }, SetOptions(merge: true));

        await db.update(
          'Manga',
          {'SyncStatus': 0},
          where: 'MangaID = ?',
          whereArgs: [mangaId],
        );
      } catch (e) {
        print('Error sincronizando manga $mangaId: $e');
      }
    }
  }

  Future<void> syncChapterTable() async {
    final db = await dbHelper.database;
    final chapters = await db.query('Chapter', where: 'SyncStatus = 1');

    for (var chapter in chapters) {
      final chapterId = chapter['ChapterID'];
      try {
        await firestore.collection('chapters').doc(chapterId as String?).set({
          'mangaId': chapter['MangaID'],
          'chapterNumber': chapter['ChapterNumber'],
          'panelsCount': chapter['PanelsCount'],
          'title': chapter['Title'],
          'synopsis': chapter['Synopsis'],
          'coverImage': chapter['CoverImage'],
          'publicationDate': chapter['PublicationDate'],
        }, SetOptions(merge: true));

        await db.update(
          'Chapter',
          {'SyncStatus': 0},
          where: 'ChapterID = ?',
          whereArgs: [chapterId],
        );
      } catch (e) {
        print('Error sincronizando capítulo $chapterId: $e');
      }
    }
  }

  Future<void> syncPanelTable() async {
    final db = await dbHelper.database;
    final panels = await db.query('Panel', where: 'SyncStatus = 1');

    for (var panel in panels) {
      final panelId = panel['PanelID'];
      try {
        await firestore.collection('panels').doc(panelId as String?).set({
          'chapterId': panel['ChapterID'],
          'imagePath': panel['ImagePath'],
          'pageNumber': panel['PageNumber'],
        }, SetOptions(merge: true));

        await db.update(
          'Panel',
          {'SyncStatus': 0},
          where: 'PanelID = ?',
          whereArgs: [panelId],
        );
      } catch (e) {
        print('Error sincronizando panel $panelId: $e');
      }
    }
  }

  Future<void> syncUserProgressTable() async {
    final db = await dbHelper.database;
    final progressList = await db.query(
      'UserProgress',
      where: 'SyncStatus = 1',
    );

    for (var progress in progressList) {
      final userId = progress['UserID'];
      try {
        await firestore.collection('user_progress').doc(userId as String?).set({
          'panelId': progress['PanelID'],
          'lastReadDate': progress['LastReadDate'],
        }, SetOptions(merge: true));

        await db.update(
          'UserProgress',
          {'SyncStatus': 0},
          where: 'UserID = ?',
          whereArgs: [userId],
        );
      } catch (e) {
        print('Error sincronizando progreso de usuario $userId: $e');
      }
    }
  }

  Future<void> syncUserNoteTable() async {
    final db = await dbHelper.database;
    final notes = await db.query('UserNote', where: 'SyncStatus = 1');

    for (var note in notes) {
      final docId = "${note['UserID']}_${note['MangaID']}";
      try {
        await firestore.collection('user_notes').doc(docId).set({
          'userId': note['UserID'],
          'mangaId': note['MangaID'],
          'comment': note['PersonalComment'],
          'rating': note['PersonalRating'],
          'isFavorited': note['IsFavorited'],
          'isPending': note['IsPending'],
          'lastEdited': note['LastEdited'],
        }, SetOptions(merge: true));

        await db.update(
          'UserNote',
          {'SyncStatus': 0},
          where: 'UserID = ? AND MangaID = ?',
          whereArgs: [note['UserID'], note['MangaID']],
        );
      } catch (e) {
        print(
          'Error sincronizando nota de usuario ${note['UserID']} - manga ${note['MangaID']}: $e',
        );
      }
    }
  }

  Future<void> syncUserSettingsTable() async {
    final db = await dbHelper.database;
    final settingsList = await db.query(
      'UserSettings',
      where: 'SyncStatus = 1',
    );

    for (var setting in settingsList) {
      final userId = setting['UserID'];
      try {
        await firestore.collection('user_settings').doc(userId as String?).set({
          'language': setting['Language'],
          'theme': setting['Theme'],
          'orientation': setting['Orientation'],
        }, SetOptions(merge: true));

        await db.update(
          'UserSettings',
          {'SyncStatus': 0},
          where: 'UserID = ?',
          whereArgs: [userId],
        );
      } catch (e) {
        print('Error sincronizando configuración de usuario $userId: $e');
      }
    }
  }

  Future<void> syncUserLibraryStructureTable() async {
    final db = await dbHelper.database;
    final folders = await db.query(
      'UserLibraryStructure',
      where: 'SyncStatus = 1',
    );

    for (var folder in folders) {
      final folderId = folder['FolderID'];
      try {
        await firestore
            .collection('user_folders')
            .doc(folderId as String?)
            .set({
              'userId': folder['UserID'],
              'folderName': folder['FolderName'],
              'description': folder['Description'],
              'parentFolderId': folder['ParentFolderID'],
            }, SetOptions(merge: true));

        await db.update(
          'UserLibraryStructure',
          {'SyncStatus': 0},
          where: 'FolderID = ?',
          whereArgs: [folderId],
        );
      } catch (e) {
        print('Error sincronizando carpeta $folderId: $e');
      }
    }
  }

  Future<void> syncFolderMangaTable() async {
    final db = await dbHelper.database;
    final relations = await db.query('FolderManga', where: 'SyncStatus = 1');

    for (var relation in relations) {
      final docId = "${relation['FolderID']}_${relation['MangaID']}";
      try {
        await firestore.collection('folder_manga').doc(docId).set({
          'folderId': relation['FolderID'],
          'mangaId': relation['MangaID'],
        }, SetOptions(merge: true));

        await db.update(
          'FolderManga',
          {'SyncStatus': 0},
          where: 'FolderID = ? AND MangaID = ?',
          whereArgs: [relation['FolderID'], relation['MangaID']],
        );
      } catch (e) {
        print(
          'Error sincronizando relación Folder-Manga ${relation['FolderID']} - ${relation['MangaID']}: $e',
        );
      }
    }
  }

  Future<void> syncAll() async {
    await syncUserTable();
    await syncAuthorTable();
    await syncMangaTable();
    await syncChapterTable();
    await syncPanelTable();
    await syncUserProgressTable();
    await syncUserNoteTable();
    await syncUserSettingsTable();
    await syncUserLibraryStructureTable();
    await syncFolderMangaTable();
  }
}
