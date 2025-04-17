// import 'package:flutter/material.dart';
// import 'package:yomuyomu/views/file_extract_view.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Yomu Yomu',
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       home: FilePickerView(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'views/library_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LibraryView(),
    );
  }
}
