import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/models/usernote_model.dart';

class NotesTab extends StatefulWidget {
  final MangaModel manga;

  const NotesTab({required this.manga});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  late TextEditingController _notesController;
  double _rating = 0;
  UserNote? _userNote;
  String _userId = 'local';

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _initUserIdAndLoadNote();
  }

  Future<void> _initUserIdAndLoadNote() async {
    final user = FirebaseAuth.instance.currentUser;
    _userId = user?.uid ?? 'local';
    await _loadUserNote();
  }

  Future<void> _loadUserNote() async {
    final db = DatabaseHelper.instance;
    final note = await db.getUserNote(_userId, widget.manga.id);
    setState(() {
      _userNote = note ??
          UserNote(
            userId: _userId,
            mangaId: widget.manga.id,
            personalComment: '',
            personalRating: 0,
            isFavorited: false,
            isPending: false,
            lastEdited: DateTime.now(),
            syncStatus: 0,
          );
      _notesController.text = _userNote?.personalComment ?? '';
      _rating = _userNote?.personalRating ?? 0;
    });
  }

  Future<void> _saveNotes() async {
    final db = DatabaseHelper.instance;

    _userNote = UserNote(
      userId: _userId,
      mangaId: widget.manga.id,
      personalComment: _notesController.text,
      personalRating: _rating,
      isFavorited: _userNote?.isFavorited ?? false,
      isPending: _userNote?.isPending ?? false,
      lastEdited: DateTime.now(),
      syncStatus: 1,
    );

    await db.insertOrUpdateUserNote(_userNote!);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userNote == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 16),
          const Text('Calificación:'),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveNotes,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
