import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yomuyomu/config/global_settings.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/chapter_model.dart';

class MangaViewer extends StatefulWidget {
  final List<Chapter> chapters;
  final Chapter initialChapter;

  const MangaViewer({
    super.key,
    required this.chapters,
    required this.initialChapter,
  });

  @override
  State<MangaViewer> createState() => _MangaViewerState();
}

class _MangaViewerState extends State<MangaViewer> {
  late Chapter _currentChapter;
  List<Uint8List> _currentImages = [];
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _loadChapterImages(_currentChapter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guardamos el tamaño de pantalla al tener contexto válido
    _screenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadChapterImages(Chapter chapter) async {
    setState(() {
      _isLoading = true;
      _currentImages.clear();
    });

    final images = <Uint8List>[];
    for (final panel in chapter.panels) {
      final file = File(panel.filePath);
      if (await file.exists()) {
        images.add(await file.readAsBytes());
      }
    }

    setState(() {
      _currentChapter = chapter;
      _currentImages = images;
      _isLoading = false;
    });
  }

  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'local_user';
  }

  Future<void> _saveProgress(String panelId) async {
    final userId = _getCurrentUserId();
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('UserProgress', {
      'UserID': userId,
      'PanelID': panelId,
      'LastReadDate': now,
      'SyncStatus': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    print("se ha guardado el userid $userId el panel $panelId");
  }

  void _goToNextChapter() {
    final index = widget.chapters.indexOf(_currentChapter);
    if (index < widget.chapters.length - 1) {
      _loadChapterImages(widget.chapters[index + 1]);
      _scrollController.jumpTo(0);
    }
  }

  void _goToPreviousChapter() {
    final index = widget.chapters.indexOf(_currentChapter);
    if (index > 0) {
      _loadChapterImages(widget.chapters[index - 1]);
      _scrollController.jumpTo(0);
    }
  }

  void _saveVisiblePanelProgress() {
    final axis = userDirectionPreference.value;
    final itemSize =
        axis == Axis.vertical ? _screenSize.height + 10 : _screenSize.width + 10;

    final index = (_scrollController.offset / itemSize).round();
    if (index >= 0 && index < _currentChapter.panels.length) {
      final panelId = _currentChapter.panels[index].id;
      _saveProgress(panelId);
    }
  }

  void _handleKey(RawKeyEvent event, Axis axis) {
    if (event is RawKeyDownEvent) {
      final isHorizontal = axis == Axis.horizontal;
      final scrollAmount = 300.0;

      if (isHorizontal) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _scrollController.animateTo(
            _scrollController.offset + scrollAmount,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _scrollController.animateTo(
            _scrollController.offset - scrollAmount,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      } else {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _scrollController.animateTo(
            _scrollController.offset + scrollAmount,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _scrollController.animateTo(
            _scrollController.offset - scrollAmount,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveVisiblePanelProgress(); // ✅ Aquí se guarda antes de salir
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentChapter.title ?? 'Chapter'),
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(color: Colors.cyanAccent),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: _isLoading ? null : _goToPreviousChapter,
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              onPressed: _isLoading ? null : _goToNextChapter,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<Axis>(
                valueListenable: userDirectionPreference,
                builder: (context, axis, _) {
                  final isVertical = axis == Axis.vertical;

                  return RawKeyboardListener(
                    focusNode: _focusNode..requestFocus(),
                    autofocus: true,
                    onKey: (event) => _handleKey(event, axis),
                    child: ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(
                        overscroll: false,
                      ),
                      child: isVertical
                          ? ListView.separated(
                              key: const PageStorageKey('manga_scroll_vertical'),
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.zero,
                              itemCount: _currentImages.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: _screenSize.width,
                                  height: _screenSize.height,
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    child: Image.memory(
                                      _currentImages[index],
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                            )
                          : ListView.separated(
                              key: const PageStorageKey('manga_scroll_horizontal'),
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              padding: EdgeInsets.zero,
                              itemCount: _currentImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                return InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.memory(
                                    _currentImages[index],
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
