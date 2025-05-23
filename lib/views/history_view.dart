import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_genres.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/models/author_model.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/views/library_view.dart';

final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    implements LibraryViewContract, FileViewContract {
  late final LibraryPresenter _libraryPresenter;
  late final FileViewModel _fileViewModel;
  late final TextEditingController _searchController;

  List<MangaModel> _mangas = [];
  Map<String, Author> _authors = {};

  @override
  void initState() {
    super.initState();
    _libraryPresenter = LibraryPresenter(this);
    _fileViewModel = FileViewModel(this);
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
      builder: (_) => _buildStatusFilterDialog(),
    );
  }

  void _showGenreFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => _buildGenreFilterDialog(),
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
      onTap: () => _libraryPresenter.sortBy(index),
    );
  }

  Widget _buildStatusFilterDialog() {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Filter By Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MangaStatus.values.map((status) {
            return CheckboxListTile(
              title: Text(status.name),
              value: filterStatus[status],
              onChanged: (value) {
                setState(() => filterStatus[status] = value!);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final selected = filterStatus.entries.where((e) => e.value).map((e) => e.key).toList();
              selected.isEmpty ? _libraryPresenter.showAll() : _libraryPresenter.filterByStatus(selected);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilterDialog() {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Filter by Genre"),
        content: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: genreFilterStatus.entries.map((entry) {
            return FilterChip(
              label: Text(entry.key),
              selected: entry.value,
              onSelected: (value) => setState(() => genreFilterStatus[entry.key] = value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final selectedGenres = genreFilterStatus.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList();
              selectedGenres.isEmpty
                  ? _libraryPresenter.showAll()
                  : _libraryPresenter.filterByGenres(selectedGenres);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  Widget _buildMangaCard(MangaModel manga) {
    final genres = manga.genres.take(3).join(" • ");
    final lastRead = manga.lastReadDate != null
        ? dateFormat.format(manga.lastReadDate!)
        : "Unknown";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
                  width: 80,
                  height: 120,
                  child:
                      manga.coverUrl != null
                          ? Image.file(
                            File(manga.coverUrl!),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          )
                          : const Icon(Icons.book),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${manga.title} - ${_authors[manga.authorId]?.name ?? manga.authorId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(genres),
                const SizedBox(height: 8),
                Text("Chapters: ${manga.totalChaptersAmount}"),
                const SizedBox(height: 4),
                Text("Last read: ${manga.lastChapterRead} ($lastRead)"),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => debugPrint("Share ${manga.title}"),
          ),
        ],
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
      body: ListView.builder(
        itemCount: _mangas.length,
        itemBuilder: (context, index) => _buildMangaCard(_mangas[index]),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
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
