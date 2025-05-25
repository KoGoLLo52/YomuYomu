import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/enums/reading_status.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/author_model.dart';
import 'package:yomuyomu/models/genre_model.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/views/manga_detail_view.dart';
import 'package:yomuyomu/widgets/delete_tab.dart';
import 'package:yomuyomu/widgets/genres_tab.dart';
import 'package:yomuyomu/widgets/note_tab.dart';
import 'package:yomuyomu/widgets/status_tab.dart';

Map<ReadingStatus, bool> filterStatus = {
  for (var status in ReadingStatus.values) status: false,
};

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    implements LibraryViewContract, FileViewContract {
  late final LibraryPresenter libraryPresenter;
  late final TextEditingController searchController;

  List<MangaModel> mangas = [];
  Map<String, Author> authors = {};
  List<GenreModel> genreList = [];
  Map<GenreModel, bool> genreFilterStatus = {};

  @override
  void initState() {
    super.initState();
    libraryPresenter = LibraryPresenter(this);
    searchController = TextEditingController();
    libraryPresenter.loadMangas();
    _loadGenresAndMangas();
  }

  Future<void> _loadGenresAndMangas() async {
    final db = DatabaseHelper.instance;
    final genres = await db.getAllGenres();
    setState(() {
      genreList = genres;
      genreFilterStatus = {for (var genre in genres) genre: false};
    });
  }

  @override
  void updateMangaList(List<MangaModel> updatedMangas) {
    setState(() {
      mangas = updatedMangas;
    });
  }

  @override
  void updateAuthorList(Map<String, Author> authorMap) {
    setState(() {
      authors = authorMap;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFilterStatusDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Filter By Status"),
            content: SingleChildScrollView(
              child: Column(
                children: ReadingStatus.values.map((status) {
                  return CheckboxListTile(
                    title: Text(status.name),
                    value: filterStatus[status],
                    onChanged: (bool? value) {
                      setState(() {
                        filterStatus[status] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  final selectedStatus = filterStatus.entries.where((e) => e.value).map((e) => e.key).toList();
                  selectedStatus.isEmpty ? libraryPresenter.showAll() : libraryPresenter.filterByStatus(selectedStatus);
                  Navigator.pop(context);
                },
                child: const Text("Accept"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGenreFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Filter by Genre"),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: genreFilterStatus.keys.map((genre) {
                  final isSelected = genreFilterStatus[genre]!;
                  return FilterChip(
                    label: Text(genre.description),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        genreFilterStatus[genre] = selected;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  final selectedGenreIds = genreFilterStatus.entries
                      .where((e) => e.value)
                      .map((e) => e.key.genreId)
                      .toList();

                  selectedGenreIds.isEmpty
                      ? libraryPresenter.showAll()
                      : libraryPresenter.filterByGenres(selectedGenreIds);
                  Navigator.pop(context);
                },
                child: const Text("Accept"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    libraryPresenter.filterMangasByTitle(query);
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("Alphabetically"), onTap: () => libraryPresenter.sortBy(0)),
          ListTile(title: const Text("Total Chapters"), onTap: () => libraryPresenter.sortBy(1)),
          ListTile(title: const Text("Rating"), onTap: () => libraryPresenter.sortBy(2)),
        ],
      ),
    );
  }

  void _showMangaOptionsPopup(MangaModel manga) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return DefaultTabController(
          length: 4,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: const TabBar(
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.amber,
                    tabs: [
                      Tab(text: 'Notes & Stars'),
                      Tab(text: 'Status'),
                      Tab(text: 'Genres'),
                      Tab(text: 'Delete'),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: 350,
                    child: TabBarView(
                      children: [
                        NotesTab(manga: manga),
                        StatusTab(
                          manga: manga,
                          onStatusChanged: (status) {
                            setState(() => manga.status = status);
                            libraryPresenter.updateMangaStatus(manga.id, status);
                          },
                        ),
                        GenresTab(
                          manga: manga,
                          onGenresUpdated: () => libraryPresenter.loadMangas(),
                        ),
                        DeleteTab(
                          manga: manga,
                          onDeleteConfirmed: () {
                            Navigator.pop(context);
                            libraryPresenter.deleteManga(manga.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMangaDetail(MangaModel selectedManga) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MangaDetailView(manga: selectedManga)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        actions: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'status') _showFilterStatusDialog();
              if (value == 'genre') _showGenreFilterDialog();
              if (value == 'sort') _showSortDialog();
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'status', child: Text('Filter by Status')),
              const PopupMenuItem(value: 'genre', child: Text('Filter by Genre')),
              const PopupMenuItem(value: 'sort', child: Text('Sort')),
            ],
          ),
        ],
      ),
      body: _buildMangaList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await libraryPresenter.importCBZFile(isVolume: true),
        tooltip: "Import CBZ Manga",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMangaList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return isWide
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                padding: const EdgeInsets.all(12),
                itemCount: mangas.length,
                itemBuilder: (_, index) => _buildMangaCard(mangas[index]),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: mangas.length,
                itemBuilder: (_, index) => _buildMangaCard(mangas[index]),
              );
      },
    );
  }

  Widget _buildMangaCard(MangaModel manga) {
    final genreDescriptions = manga.genres
        .map((id) => genreList.firstWhere(
              (genre) => genre.genreId == id,
              orElse: () => GenreModel(genreId: id, description: id),
            ))
        .map((g) => g.description)
        .take(3)
        .join(" • ");
    final authorName = authors[manga.authorId]?.name ?? manga.authorId;

    return GestureDetector(
      onTap: () => _openMangaDetail(manga),
      onLongPress: () => _showMangaOptionsPopup(manga),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                      )
                    : const Icon(Icons.book, size: 64),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manga.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    Text(authorName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Text(genreDescriptions,
                        style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.menu_book, size: 16),
                        const SizedBox(width: 4),
                        Text("Ch: ${manga.totalChaptersAmount}"),
                        const SizedBox(width: 16),
                        const Icon(Icons.auto_stories, size: 16),
                        const SizedBox(width: 4),
                        Text("Pg: ${manga.chapterProgress}"),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  manga.isFavorited ? Icons.star : Icons.star_border,
                  color: manga.isFavorited ? Colors.amber : Colors.grey,
                ),
                onPressed: () async {
                  await libraryPresenter.toggleFavoriteStatus(manga);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void showLoading() {}

  @override
  void hideLoading() {}

  @override
  void showMangaDetails(MangaModel manga) {}

  @override
  void showImagesInMemory(List<Uint8List> imageData) {}
}
