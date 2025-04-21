import 'dart:io';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/models/manga.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/views/manga_viewer.dart';

final DateFormat shortDate = DateFormat('dd/MM/yyyy');

Map<MangaStatus, bool> filterStatus = {
  MangaStatus.cancelled: false,
  MangaStatus.hiatus: false,
  MangaStatus.ongoing: false,
  MangaStatus.completed: false,
};

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView>
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
                onChanged: (query) {
                  _onSearchChanged(query);
                },
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text("Filter", style: TextStyle(fontSize: 14)),
            onPressed: _showFilterStatusDialog,
          ),
          TextButton.icon(
            icon: const Icon(Icons.sort, size: 18),
            label: const Text("Sort", style: TextStyle(fontSize: 14)),
            onPressed: _showSortDialog),
        ],
      ),
      body: ListView.builder(
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          Manga manga = mangas[index];
          List<String> genres = manga.genres;
          String displayedGenres = genres.take(3).join(" • ");

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
                  // child: Image.network(
                  //   manga.coverUrl,
                  //   fit: BoxFit.cover,
                  // ),
                  child: Icon(Icons.book),
                ),
                const SizedBox(width: 10),
                // Información del manga
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
                      Text(
                        "Siguiente capítulo: ${shortDate.format(manga.nextPublicationDate)}",
                      ),
                      Text(
                        "Inicio de publicación: ${shortDate.format(manga.startPublicationDate)}",
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    print("Compartir ${manga.title}");
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
