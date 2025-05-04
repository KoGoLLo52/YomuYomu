import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_genres.dart';
import 'package:yomuyomu/contracts/manga_contract.dart';
import 'package:yomuyomu/presenters/manga_presenter.dart';
import 'package:yomuyomu/models/manga.dart';
import 'package:yomuyomu/contracts/library_contract.dart';
import 'package:yomuyomu/presenters/library_presenter.dart';
import 'package:yomuyomu/views/browse_view.dart';
import 'package:yomuyomu/views/library_view.dart';
import 'package:yomuyomu/views/manga_viewer.dart';

final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    implements LibraryViewContract, FileViewContract {
  late LibraryPresenter _libraryPresenter;
  late FileViewModel _fileViewModel;
  late TextEditingController _searchController;
  List<Manga> _mangas = [];

  @override
  void initState() {
    super.initState();
    _libraryPresenter = LibraryPresenter(this);
    _fileViewModel = FileViewModel(this);
    _searchController = TextEditingController();
    _libraryPresenter.loadMangas();
  }

  @override
  void updateMangaList(List<Manga> updatedMangas) {
    setState(() {
      _mangas = updatedMangas;
    });
  }

  @override
  void showError(String errorMessage) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  void showImages(List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MangaViewer(mangaImages: images)),
    );
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
                          title: Text(status.toString()),
                          value: _getFilterStatus(status),
                          onChanged: (isSelected) {
                            setState(() {
                              _toggleStatusFilter(status, isSelected!);
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
                    final selectedStatuses = _getSelectedStatuses();
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
                        return FilterChip(
                          label: Text(genre),
                          selected: genreFilterStatus[genre]!,
                          onSelected: (isSelected) {
                            setState(() {
                              genreFilterStatus[genre] = isSelected;
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
                    final selectedGenres = _getSelectedGenres();
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
              _buildSortOption("Alphabetically", 0),
              _buildSortOption("Total Chapters", 1),
              _buildSortOption("Rating", 2),
            ],
          ),
    );
  }

  ListTile _buildSortOption(String label, int option) {
    return ListTile(
      title: Text(label),
      onTap: () => _libraryPresenter.sortBy(option),
    );
  }

  bool _getFilterStatus(MangaStatus status) {
    return filterStatus[status] ?? false;
  }

  void _toggleStatusFilter(MangaStatus status, bool isSelected) {
    filterStatus[status] = isSelected;
  }

  List<MangaStatus> _getSelectedStatuses() {
    return filterStatus.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  List<String> _getSelectedGenres() {
    return genreFilterStatus.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Browse"),
        actions: [
          _buildSearchBar(),
          _buildFilterButton(),
          _buildGenreButton(),
          _buildSortButton(),
        ],
      ),
      body: ListView.builder(
        itemCount: _mangas.length,
        itemBuilder: (context, index) {
          final manga = _mangas[index];
          final genres = manga.genres.take(3).join(" • ");
          return _buildMangaCard(manga, genres);
        },
      ),
    );
  }

  Padding _buildSearchBar() {
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

  IconButton _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: _showStatusFilterDialog,
    );
  }

  IconButton _buildGenreButton() {
    return IconButton(
      icon: const Icon(Icons.label),
      onPressed: _showGenreFilterDialog,
    );
  }

  IconButton _buildSortButton() {
    return IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog);
  }

  Container _buildMangaCard(Manga manga, String genres) {
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
          SizedBox(width: 80, height: 120, child: const Icon(Icons.book)),
          const SizedBox(width: 10),
          _buildMangaInfo(manga, genres),
          _buildShareButton(manga),
        ],
      ),
    );
  }

  Expanded _buildMangaInfo(Manga manga, String genres) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${manga.title}    ${manga.author}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(genres),
          const SizedBox(height: 8),
          Text("Chapters: ${manga.totalChaptersAmount}"),
          const SizedBox(height: 4),
          Text("Last read Chapter: ${manga.lastChapterRead}"),
        ],
      ),
    );
  }

  IconButton _buildShareButton(Manga manga) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {
        print("Compartir ${manga.title}");
      },
    );
  }
}
