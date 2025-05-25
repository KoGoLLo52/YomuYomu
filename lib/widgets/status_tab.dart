import 'package:flutter/material.dart';
import 'package:yomuyomu/enums/reading_status.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/manga_model.dart';

class StatusTab extends StatefulWidget {
  final MangaModel manga;
  final Function(ReadingStatus) onStatusChanged;

  const StatusTab({
    super.key,
    required this.manga,
    required this.onStatusChanged,
  });

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  late ReadingStatus selectedStatus;
  bool isLoading = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    _initUserAndLoadStatus();
  }

  Future<void> _initUserAndLoadStatus() async {
  final db = DatabaseHelper.instance;
  userId = await db.getSingleUserID() ?? 'local';

  await _loadStatusFromDb();
}

  Future<void> _loadStatusFromDb() async {
    final db = DatabaseHelper.instance;
    ReadingStatus statusFromDb = widget.manga.status;

    final note = await db.getUserNoteForManga(userId, widget.manga.id);
    final status = note?.readingStatus;
    if (status != null) {
      statusFromDb = status;
    }

    setState(() {
      selectedStatus = statusFromDb;
      isLoading = false;
    });
  }

  Future<void> _saveStatus(ReadingStatus newStatus) async {
    final db = DatabaseHelper.instance;
    await db.updateMangaStatus(
      userId: userId,
      mangaId: widget.manga.id,
      readingStatus: newStatus.value,
    );

    setState(() {
      selectedStatus = newStatus;
      widget.manga.status = newStatus;
    });

    widget.onStatusChanged(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children:
          ReadingStatus.values.map((status) {
            return RadioListTile<ReadingStatus>(
              title: Text(status.name),
              value: status,
              groupValue: selectedStatus,
              onChanged: (ReadingStatus? newValue) {
                if (newValue != null) {
                  _saveStatus(newValue);
                }
              },
            );
          }).toList(),
    );
  }
}
