import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yomuyomu/extractData.dart';

void main() {
  runApp(MyApp());
}

final List<File> testImages = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yomu Yomu',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ButtonWidget(),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yomu Yomu')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => pickAndOpen(context),
          child: Text('Open file'),
        ),
      ),
    );
  }
}

class CBZViewer extends StatelessWidget {
  final List<File> images;
  const CBZViewer({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // Agrupar imágenes de 2 en 2 para mostrarlas lado a lado
    final pages = <List<File>>[];
    for (int i = 0; i < images.length; i += 2) {
      pages.add(
        images.sublist(i, (i + 2 > images.length) ? images.length : i + 2),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Manga')),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        pageSnapping: false,
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final pageImages = pages[index];
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              for (var image in pageImages)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 50),

                    child: Image.file(
                      image,
                      fit: BoxFit.fill,
                      height: double.infinity,
                    ),
                  ),
                ),
              if (pageImages.length == 1) const Expanded(child: SizedBox()),
            ],
          );
        },
      ),
    );
  }
}
