import 'dart:io';
import 'package:flutter/material.dart';

final int screenDoubleImageSize = 1200;
final Axis userDirectionPreference = Axis.vertical;

class MangaViewer extends StatelessWidget {
  final List<File> images;
  const MangaViewer({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final pages = groupPagesByWidth(context, images);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Manga'),
        titleTextStyle: TextStyle(color: Colors.cyanAccent),
        iconTheme: IconThemeData(
          color:
              Colors
                  .white, // Cambia el color del botón de retroceso (la flecha)
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body:
          images.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : PageView.builder(
                scrollDirection: userDirectionPreference,
                physics: const BouncingScrollPhysics(),
                pageSnapping: false,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final pageImages = pages[index];
                  final bool showJustOne = pageImages.length == 1;

                  final bool isLastIncompleteRow =
                      showJustOne &&
                      index == pages.length - 1 &&
                      MediaQuery.of(context).size.width > screenDoubleImageSize;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var image in pageImages)
                          Flexible(
                            flex: 1,
                            child: ClipRect(
                              child: Image.file(
                                image,
                                fit:
                                    pageImages.length == 2
                                        ? BoxFit.fill
                                        : BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        if (isLastIncompleteRow)
                          const Flexible(
                            flex: 1,
                            child:
                                SizedBox(), // Espacio para segunda imagen inexistente
                          ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  List<List<File>> groupPagesByWidth(BuildContext context, List<File> images) {
    final double screenWidth = MediaQuery.of(context).size.width;
    int imagesPerRow = screenWidth > screenDoubleImageSize ? 2 : 1;

    List<List<File>> pages = [];

    for (int i = 0; i < images.length; i += imagesPerRow) {
      pages.add(
        images.sublist(
          i,
          (i + imagesPerRow > images.length) ? images.length : i + imagesPerRow,
        ),
      );
    }
    return pages;
  }
}
