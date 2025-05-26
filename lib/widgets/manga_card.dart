import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yomuyomu/models/manga_model.dart';
import 'package:yomuyomu/models/genre_model.dart';

class MangaCard extends StatelessWidget {
  final MangaModel manga;
  final String authorName;
  final List<GenreModel> genreList;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showLastReadDate;
  final bool showFavoriteIcon;
  final VoidCallback? onFavoriteToggle;

  const MangaCard({
    super.key,
    required this.manga,
    required this.authorName,
    required this.genreList,
    this.onTap,
    this.onLongPress,
    this.showLastReadDate = false,
    this.showFavoriteIcon = true,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final genreDescriptions = manga.genres
        .map((id) => genreList.firstWhere(
              (genre) => genre.genreId == id,
              orElse: () => GenreModel(genreId: id, description: id),
            ))
        .map((g) => g.description)
        .take(3)
        .join(" • ");

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      manga.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authorName,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      genreDescriptions,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    if (showLastReadDate && manga.lastReadDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(manga.lastReadDate!),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (showFavoriteIcon)
                IconButton(
                  icon: Icon(
                    manga.isFavorited ? Icons.star : Icons.star_border,
                    color: manga.isFavorited ? Colors.amber : Colors.grey,
                  ),
                  onPressed: onFavoriteToggle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
