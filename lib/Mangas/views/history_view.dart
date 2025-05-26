import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/Mangas/models/author_model.dart';
import 'package:yomuyomu/Mangas/models/manga_model.dart';
import 'package:yomuyomu/Mangas/presenters/library_presenter.dart';
import 'package:yomuyomu/Mangas/contracts/library_contract.dart';

final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    implements LibraryViewContract {
  late final LibraryPresenter _libraryPresenter;
  late final TextEditingController _searchController;

  List<MangaModel> _mangas = [];
  Map<String, Author> _authors = {};

  @override
  void initState() {
    super.initState();
    _libraryPresenter = LibraryPresenter(this);
    _searchController = TextEditingController();
    _libraryPresenter.loadMangas();
  }

  @override
  void updateMangaList(List<MangaModel> updatedMangas) {
    setState(() {
      _mangas = List.from(updatedMangas)
        ..sort((a, b) => b.lastReadDate?.compareTo(a.lastReadDate ?? DateTime(0)) ?? 0);
    });
  }

  @override
  void updateAuthorList(Map<String, Author> authorMap) {
    setState(() {
      _authors = authorMap;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged(String query) {
    _libraryPresenter.filterMangasByTitle(query);
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter By Status"),
        content: const Text("Status filter not implemented yet."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showGenreFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter By Genre"),
        content: const Text("Genre filter not implemented yet."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption("Alphabetically", 0),
          _buildSortOption("Total Chapters", 1),
          _buildSortOption("Rating", 2),
        ],
      ),
    );
  }

  ListTile _buildSortOption(String label, int index) {
    return ListTile(
      title: Text(label),
      onTap: () {
        _libraryPresenter.sortBy(index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMangaCard(MangaModel manga) {
    final authorName = _authors[manga.authorId]?.name ?? manga.authorId;
    final genres = manga.genres.take(3).join(" • ");
    final lastRead = manga.lastReadDate != null
        ? dateFormat.format(manga.lastReadDate!)
        : "Unknown";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: manga.coverUrl != null
                  ? Image.file(
                      File(manga.coverUrl!),
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 48),
                    )
                  : const Icon(Icons.book, size: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(manga.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  Text(authorName,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Text(genres,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 16),
                      const SizedBox(width: 4),
                      Text("Ch: ${manga.totalChaptersAmount}"),
                      const SizedBox(width: 16),
                      const Icon(Icons.auto_stories, size: 16),
                      const SizedBox(width: 4),
                      Text("Pg: ${manga.lastChapterRead}"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Last read: $lastRead",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => debugPrint("Share ${manga.title}"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          _buildSearchField(),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showStatusFilterDialog),
          IconButton(icon: const Icon(Icons.label), onPressed: _showGenreFilterDialog),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return isWide
              ? GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: _mangas.length,
                  itemBuilder: (_, index) => _buildMangaCard(_mangas[index]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _mangas.length,
                  itemBuilder: (_, index) => _buildMangaCard(_mangas[index]),
                );
        },
      ),
    );
  }

  @override
  void hideLoading() {}

  @override
  void showLoading() {}

  @override
  void showMangaDetails(MangaModel manga) {}

  @override
  void showImagesInMemory(List<Uint8List> imageData) {}
}
