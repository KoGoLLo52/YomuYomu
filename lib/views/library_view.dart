import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
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

Map<MangaStatus, bool> filterStatus = {
  MangaStatus.cancelled: false,
  MangaStatus.hiatus: false,
  MangaStatus.ongoing: false,
  MangaStatus.completed: false,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFilterStatusDialog() {
    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Filter By Status"),
                content: SingleChildScrollView(
                  child: Column(
                    children:
                        MangaStatus.values.map((status) {
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      final selectedStatus =
                          filterStatus.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();
                      selectedStatus.isEmpty
                          ? libraryPresenter.showAll()
                          : libraryPresenter.filterByStatus(selectedStatus);
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
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Filter by Genre"),
                content: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        genreFilterStatus.keys.map((genre) {
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      final selectedGenreIds =
                          genreFilterStatus.entries
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
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Alphabetically"),
                onTap: () => libraryPresenter.sortBy(0),
              ),
              ListTile(
                title: const Text("Total Chapters"),
                onTap: () => libraryPresenter.sortBy(1),
              ),
              ListTile(
                title: const Text("Rating"),
                onTap: () => libraryPresenter.sortBy(2),
              ),
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
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Notes & Stars'),
                    Tab(text: 'Genres'),
                    Tab(text: 'Delete'),
                  ],
                ),
                Flexible(
                  child: TabBarView(
                    children: [
                      NotesTab(manga: manga),
                      GenresTab(
                        manga: manga,
                        onGenresUpdated: () {
                          libraryPresenter.loadMangas();
                        },
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMangaDetail(MangaModel selectedManga) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MangaDetailView(manga: selectedManga)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        actions: [
          _buildSearchField(),
          _buildFilterButton(),
          _buildGenreFilterButton(),
          _buildSortButton(),
        ],
      ),
      body: _buildMangaList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await libraryPresenter.importCBZFile(isVolume: true);
        },
        tooltip: "Import CBZ Manga",
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return TextButton.icon(
      icon: const Icon(Icons.filter_list, size: 18),
      label: const Text("Filter", style: TextStyle(fontSize: 14)),
      onPressed: _showFilterStatusDialog,
    );
  }

  Widget _buildGenreFilterButton() {
    return TextButton.icon(
      icon: const Icon(Icons.label, size: 18),
      label: const Text("Genres", style: TextStyle(fontSize: 14)),
      onPressed: _showGenreFilterDialog,
    );
  }

  Widget _buildSortButton() {
    return TextButton.icon(
      icon: const Icon(Icons.sort, size: 18),
      label: const Text("Sort", style: TextStyle(fontSize: 14)),
      onPressed: _showSortDialog,
    );
  }

  Widget _buildMangaList() {
    return ListView.builder(
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        final genreDescriptions = manga.genres
            .map(
              (id) => genreList.firstWhere(
                (genre) => genre.genreId == id,
                orElse: () => GenreModel(genreId: id, description: id),
              ),
            )
            .map((g) => g.description)
            .take(3)
            .join(" • ");

        final authorName = authors[manga.authorId]?.name ?? manga.authorId;

        return InkWell(
          onTap: () => _openMangaDetail(manga),
          onLongPress: () => _showMangaOptionsPopup(manga),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                (_, __, ___) => const Icon(Icons.broken_image),
                          )
                          : const Icon(Icons.book),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${manga.title}    $authorName",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(genreDescriptions),
                      const SizedBox(height: 8),
                      Text("Chapters: ${manga.totalChaptersAmount}"),
                      const SizedBox(height: 4),
                      Text("Progress: ${manga.chapterProgress}"),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        manga.isStarred ? Icons.star : Icons.star_border,
                        color: manga.isStarred ? Colors.amber : null,
                      ),
                      onPressed: () {
                        setState(() {
                          mangas[index].isStarred = !mangas[index].isStarred;
                        });
                      },
                    ),
                    if (manga.isPending)
                      const Text("Pending", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
