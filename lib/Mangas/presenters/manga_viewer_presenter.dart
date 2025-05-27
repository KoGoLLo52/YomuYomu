import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:yomuyomu/Mangas/contracts/manga_viewer_contract.dart';
import 'package:yomuyomu/DataBase/database_helper.dart';
import 'package:yomuyomu/Mangas/helpers/event_bus_helpder.dart';
import 'package:yomuyomu/Account/helpers/user_session_helper.dart';
import 'package:yomuyomu/Mangas/models/chapter_model.dart';

class MangaViewerPresenter {
  final MangaViewerViewContract view;

  MangaViewerPresenter(this.view);

  Future<void> loadChapterImages(Chapter chapter) async {
    view.showLoading();

    final images = <Uint8List>[];
    for (final panel in chapter.panels) {
      final file = File(panel.filePath);
      if (await file.exists()) {
        images.add(await file.readAsBytes());
      }
    }

    view.updateChapter(chapter, images);
    view.hideLoading();
  }

  Future<void> saveProgress(String panelId) async {
    final userId = await UserSession.getStoredUserId();
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('UserProgress', {
      'UserID': userId,
      'PanelID': panelId,
      'LastReadDate': now,
      'SyncStatus': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    
    EventBus().fire('progress_saved');
    print("Se ha guardado el userid $userId el panel $panelId");
  }
}
