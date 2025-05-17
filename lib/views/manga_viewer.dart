import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_settings.dart';

const double doublePageWidthThreshold = 1200;

class MangaViewer extends StatelessWidget {
  final List<Uint8List> mangaImages;

  const MangaViewer({super.key, required this.mangaImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Manga'),
        titleTextStyle: const TextStyle(color: Colors.cyanAccent),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: mangaImages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<Axis>(
              valueListenable: userDirectionPreference,
              builder: (context, axis, _) {
                final bool isDoublePageLayout = MediaQuery.of(context).size.width > doublePageWidthThreshold;
                final groupedPages = _groupImagesIntoPages(mangaImages, isDoublePageLayout);

                return PageView.builder(
                  scrollDirection: axis,
                  physics: const BouncingScrollPhysics(),
                  pageSnapping: true,
                  itemCount: groupedPages.length,
                  itemBuilder: (context, index) {
                    final pageImages = groupedPages[index];
                    return _buildPageView(pageImages);
                  },
                );
              },
            ),
    );
  }

  List<List<Uint8List>> _groupImagesIntoPages(List<Uint8List> images, bool isDoublePageLayout) {
    final int imagesPerPage = isDoublePageLayout ? 2 : 1;
    final List<List<Uint8List>> pages = [];

    for (int i = 0; i < images.length; i += imagesPerPage) {
      final pageImages = images.sublist(
        i,
        (i + imagesPerPage > images.length) ? images.length : i + imagesPerPage,
      );
      pages.add(pageImages);
    }

    return pages;
  }

  Widget _buildPageView(List<Uint8List> pageImages) {
    if (pageImages.length == 1) {
      return Center(
        child: Image.memory(
          pageImages[0],
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          width: double.infinity,
        ),
      );
    } else {
      return Row(
        children: pageImages.map((imageData) {
          return Expanded(
            child: Image.memory(
              imageData,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          );
        }).toList(),
      );
    }
  }
}
