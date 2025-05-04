import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_genres.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/models/manga.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/views/manga_detail_view.dart';
import 'package:yomuyomu/views/manga_viewer.dart';

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
  late LibraryPresenter libraryPresenter;
  List<Manga> mangas = [];
  late FileViewModel fileViewModel;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    libraryPresenter = LibraryPresenter(this);
    fileViewModel = FileViewModel(this);
    _searchController = TextEditingController();
    libraryPresenter.loadMangas();
  }

  @override
  void updateMangaList(List<Manga> updatedMangas) {
    setState(() {
      mangas = updatedMangas;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void showImages(List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MangaViewer(mangaImages: images,)),
    );
  }

  void _showFilterStatusDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Filter By Status"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...MangaStatus.values.map((status) => CheckboxListTile(
                          title: Text(status.name),
                          value: filterStatus[status],
                          onChanged: (bool? newValue) {
                            setState(() {
                              filterStatus[status] = newValue!;
                            });
                          },
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    List<MangaStatus> selectedStatus =
                        filterStatus.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                    if (selectedStatus.isEmpty) {
                      libraryPresenter.showAll();
                    } else {
                      libraryPresenter.filterByStatus(selectedStatus);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Accept"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGenreFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
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
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (bool selected) {
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
                    List<String> selectedGenres =
                        genreFilterStatus.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                    if (selectedGenres.isEmpty) {
                      libraryPresenter.showAll();
                    } else {
                      libraryPresenter.filterByGenres(selectedGenres);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Accept"),
                ),
              ],
            );
          },
        );
      },
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

  void _openMangaDetail(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MangaDetailView()),
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
        Manga manga = mangas[index];
        List<String> genres = manga.genres;
        String displayedGenres = genres.take(3).join(" • ");

        return InkWell(
          onTap: () => _openMangaDetail(mangas[index].filePath),
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
                SizedBox(width: 80, height: 120, child: Icon(Icons.book)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${manga.title}    ${manga.author}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(displayedGenres),
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
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
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
                    ),
                    Text(
                      mangas[index].isPending ? "Pending" : "",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
