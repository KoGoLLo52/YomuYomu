import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_genres.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';

final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

Map<MangaStatus, bool> mangaStatusFilter = {
  MangaStatus.cancelled: false,
  MangaStatus.hiatus: false,
  MangaStatus.ongoing: false,
  MangaStatus.completed: false,
};

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  _BrowseViewState createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView>
    implements LibraryViewContract, FileViewContract {
  late LibraryPresenter _libraryPresenter;
  List<Manga> _mangas = [];
  bool _isLoading = true;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _libraryPresenter = LibraryPresenter(this);
    _searchController = TextEditingController();
    _libraryPresenter.loadMangas();
  }

  @override
  void updateMangaList(List<Manga> updatedMangas) {
    setState(() {
      _mangas = updatedMangas;
      _isLoading = false;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showStatusFilterDialog() {
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
                  children:
                      MangaStatus.values.map((status) {
                        return CheckboxListTile(
                          title: Text(status.toString().split('.').last),
                          value: mangaStatusFilter[status],
                          onChanged: (bool? newValue) {
                            setState(() {
                              mangaStatusFilter[status] = newValue!;
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
                    final selectedStatuses =
                        mangaStatusFilter.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                    if (selectedStatuses.isEmpty) {
                      _libraryPresenter.showAll();
                    } else {
                      _libraryPresenter.filterByStatus(selectedStatuses);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
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
                  children:
                      genreFilterStatus.keys.map((genre) {
                        final isSelected = genreFilterStatus[genre]!;
                        return FilterChip(
                          label: Text(genre),
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
                    final selectedGenres =
                        genreFilterStatus.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                    if (selectedGenres.isEmpty) {
                      _libraryPresenter.showAll();
                    } else {
                      _libraryPresenter.filterByGenres(selectedGenres);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    _libraryPresenter.filterMangasByTitle(query);
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
                onTap: () => _libraryPresenter.sortBy(0),
              ),
              ListTile(
                title: const Text("Total Chapters"),
                onTap: () => _libraryPresenter.sortBy(1),
              ),
              ListTile(
                title: const Text("Rating"),
                onTap: () => _libraryPresenter.sortBy(2),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse"),
        actions: [
          Padding(
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
          ),
          TextButton.icon(
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text("Filter", style: TextStyle(fontSize: 14)),
            onPressed: _showStatusFilterDialog,
          ),
          TextButton.icon(
            icon: const Icon(Icons.label, size: 18),
            label: const Text("Genres", style: TextStyle(fontSize: 14)),
            onPressed: _showGenreFilterDialog,
          ),
          TextButton.icon(
            icon: const Icon(Icons.sort, size: 18),
            label: const Text("Sort", style: TextStyle(fontSize: 14)),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _mangas.length,
                itemBuilder: (context, index) {
                  final manga = _mangas[index];
                  final genres = manga.genres;
                  final displayedGenres = genres.take(3).join(" • ");

                  return Container(
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
                          child: Icon(Icons.book),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${manga.title}    ${manga.authorId}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(displayedGenres),
                              const SizedBox(height: 8),
                              Text("Chapters: ${manga.totalChaptersAmount}"),
                              const SizedBox(height: 4),
                              Text(
                                "Next Chapter: ${manga.nextPublicationDate != null ? dateFormat.format(manga.nextPublicationDate!) : 'N/A'}",
                              ),
                              Text(
                                "Start Publication: ${dateFormat.format(manga.startPublicationDate)}",
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            print("Share ${manga.title}");
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
  
  @override
  void hideLoading() {
    // TODO: implement hideLoading
  }
  
  @override
  void showLoading() {
    // TODO: implement showLoading
  }
  
  @override
  void showMangaDetails(Manga manga) {
    // TODO: implement showMangaDetails
  }

  @override
  void showImagesInMemory(List<Uint8List> imageData) {
    // TODO: implement showImagesInMemory
  }
}
