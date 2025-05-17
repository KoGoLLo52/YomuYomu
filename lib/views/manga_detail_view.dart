import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/models/chapter_model.dart';
import 'package:yomuyomu/contracts/manga_detail_contract.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/presenters/manga_detail_presenter.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/views/manga_viewer.dart';

class MangaDetailView extends StatefulWidget {
  final Manga manga;
  const MangaDetailView({super.key, required this.manga});

  @override
  State<MangaDetailView> createState() => _MangaDetailViewState();
}

class _MangaDetailViewState extends State<MangaDetailView>
    implements MangaDetailViewContract, FileViewContract {
  late MangaDetailPresenter _presenter;
  late FileViewModel _fileViewModel;
  final TextEditingController _searchController = TextEditingController();

  Manga? _currentManga;
  List<Chapter> _availableChapters = [];

  @override
  void initState() {
    super.initState();
    _presenter = MangaDetailPresenter(this);
    _fileViewModel = FileViewModel(this);
    _searchController.addListener(_onSearchChanged);
    _presenter.loadMangaDetail(widget.manga.id);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _presenter.loadMangaDetail(widget.manga.id);
    } else {
      _presenter.searchChapter(query);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onChapterSelected(Chapter chapter) async {
    // Asegúrate de que chapter.chapterId esté definido y coincida con CBZHandler
    await _fileViewModel.openSpecificChapter(chapter.filePath, chapter.id);
  }

  @override
  void showManga(Manga manga) {
    setState(() {
      _currentManga = manga;
    });
  }

  @override
  void showChapters(List<Chapter> chapters) {
    setState(() {
      _availableChapters = chapters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manga Details")),
      body: _currentManga == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMangaHeader(),
                _buildSynopsis(),
                _buildChapterSection(),
                _buildChapterSearchField(),
                _buildChapterList(),
              ],
            ),
    );
  }

  Widget _buildMangaHeader() {
    return ListTile(
      leading: Image.network(
        _currentManga!.coverUrl ?? 'https://example.com/default.jpg',
      ),
      title: Text(_currentManga!.title),
      subtitle: Text("by ${_currentManga!.authorId}"),
    );
  }

  Widget _buildSynopsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        _currentManga!.synopsis ?? 'No synopsis available.',
        style: const TextStyle(fontSize: 14.0),
      ),
    );
  }

  Widget _buildChapterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Chapters",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            _availableChapters.sort(
              (a, b) => a.publicationDate!.compareTo(b.publicationDate!),
            );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildChapterSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Find Chapter",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildChapterList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _availableChapters.length,
        itemBuilder: (_, index) {
          final chapter = _availableChapters[index];
          return ListTile(
            leading: Image.network(
              chapter.coverUrl ?? 'https://example.com/default.jpg',
            ),
            title: Text(chapter.title ?? 'No Title'),
            subtitle: Text("Published: ${chapter.publicationDate}"),
            onTap: () => _onChapterSelected(chapter),
          );
        },
      ),
    );
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void showImagesInMemory(List<Uint8List> imageData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaViewer(mangaImages: imageData),
      ),
    );
  }

  // Métodos sin implementar (según contrato, pero no usados)
  @override
  void showImages(List<File> images) {}

  @override
  void hideLoading() {}

  @override
  void showLoading() {}

  @override
  void showMangaDetails(Manga manga) {}
}
