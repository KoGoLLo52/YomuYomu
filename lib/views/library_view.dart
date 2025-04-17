import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/models/manga.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/views/manga_viewer.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    implements LibraryViewContract,FileViewContract {
  late LibraryPresenter presenter;
  List<Manga> mangas = [];
  late FileViewModel fileViewModel;

  @override
  void initState() {
    super.initState();
    presenter = LibraryPresenter(this);
    fileViewModel = FileViewModel(this);
    presenter.loadMangas();
  }

  @override
  void updateMangaList(List<Manga> updatedMangas) {
    setState(() {
      mangas = updatedMangas;
    });
  }

  @override
void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

@override
void showImages(List<File> images) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MangaViewer(images: images),
    ),
  );
}


  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Unread"),
                onTap: () => presenter.filterByStatus("Unread"),
              ),
              ListTile(
                title: const Text("Pending"),
                onTap: () => presenter.filterByStatus("Pending"),
              ),
              ListTile(
                title: const Text("Completed"),
                onTap: () => presenter.filterByStatus("Completed"),
              ),
            ],
          ),
    );
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
                onTap: () => presenter.sortBy("Alphabetically"),
              ),
            ],
          ),
    );
  }

  // Método para abrir el archivo del manga
  void _openMangaFile(String filePath) {
    fileViewModel.openFileFromLocation(
      filePath,
    ); // Llamas al método para abrir el archivo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        actions: [
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
            title: Text("${manga.title} - ${manga.author}"),
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
                  mangas[index] = Manga(
                    title: manga.title,
                    author: manga.author,
                    sinopsis: manga.sinopsis,
                    rating: manga.rating,
                    startPublicationDate: manga.startPublicationDate,
                    nextPublicationDate: manga.nextPublicationDate,
                    genres: manga.genres,
                    status: manga.status,
                    chapterProgress: manga.chapterProgress,
                    isStarred: !manga.isStarred,
                    filePath: manga.filePath, // No olvides pasar el filePath
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }
}
