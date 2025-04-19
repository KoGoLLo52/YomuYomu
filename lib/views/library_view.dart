import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/models/manga.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void showImages(List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MangaViewer(images: images)),
    );
  }

  void _showFilterDialog() {
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
                    CheckboxListTile(
                      title: const Text("Cancelled"),
                      value: filterStatus[MangaStatus.cancelled],
                      onChanged: (bool? newValue) {
                        setState(() {
                          filterStatus[MangaStatus.cancelled] = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Hiatus"),
                      value: filterStatus[MangaStatus.hiatus],
                      onChanged: (bool? newValue) {
                        setState(() {
                          filterStatus[MangaStatus.hiatus] = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("OnGoing"),
                      value: filterStatus[MangaStatus.ongoing],
                      onChanged: (bool? newValue) {
                        setState(() {
                          filterStatus[MangaStatus.ongoing] = newValue!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Completed"),
                      value: filterStatus[MangaStatus.completed],
                      onChanged: (bool? newValue) {
                        setState(() {
                          filterStatus[MangaStatus.completed] = newValue!;
                        });
                      },
                    ),
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

  void _openMangaFile(String filePath) {
    fileViewModel.openFileFromLocation(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
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
                onChanged: (query) {
                  _onSearchChanged(query);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
        ],
      ),
      body: ListView.builder(
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          Manga manga = mangas[index];
          List<String> genres = manga.genres;
          String displayedGenres = genres.take(3).join(" • ");

          return ListTile(
            leading: const Icon(Icons.book),
            title: Text("${manga.title} - ${manga.author} - ${manga.rating}"),
            subtitle: Text(displayedGenres),
            onTap:
                () => _openMangaFile(
                  manga.filePath,
                ), // Abre el archivo al hacer tap
            trailing: IconButton(
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
          );
        },
      ),
    );
  }
}
