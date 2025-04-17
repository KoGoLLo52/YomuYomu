import 'dart:io';
import 'package:flutter/material.dart';

class MangaViewer extends StatelessWidget {
  final List<File> images;
  const MangaViewer({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final pages = <List<File>>[];
    for (int i = 0; i < images.length; i += 2) {
      pages.add(
        images.sublist(i, (i + 2 > images.length) ? images.length : i + 2),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Manga')),
      body: images.isEmpty 
          ? const Center(child: CircularProgressIndicator()) 
          : PageView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              pageSnapping: false,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final pageImages = pages[index];
                return Row(
                  children: [
                    for (var image in pageImages)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Image.file(
                            image,
                            fit: BoxFit.fill,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    if (pageImages.length == 1)
                      const Expanded(child: SizedBox()),
                  ],
                );
              },
            ),
    );
  }
}
