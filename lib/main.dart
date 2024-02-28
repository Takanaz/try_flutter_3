import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'env/env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List<PixabayImage> pixabayImages = [];

  Future<void> fetchImages(String text) async {
    final response =
        await Dio().get('https://pixabay.com/api', queryParameters: {
      'key': Env.pixabayApiKey,
      'q': text,
      'image_type': 'photo',
      'pretty': true,
      'per_page': 100,
    });
    final List hits = response.data['hits'];
    pixabayImages = hits.map((e) => PixabayImage.fromMap(e)).toList();

    setState(() {});
  }

  Future<void> shareImage(String url) async {
    final tempDir = await getTemporaryDirectory();
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final imageFile =
        await File('${tempDir.path}/image.png').writeAsBytes(response.data);
    await Share.shareXFiles([XFile(imageFile.path)]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            decoration:
                const InputDecoration(fillColor: Colors.white, filled: true),
            onFieldSubmitted: (text) {
              fetchImages(text);
            },
          ),
          backgroundColor: Colors.purple.shade100,
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: pixabayImages.length,
          itemBuilder: (context, index) {
            final pixabayImage = pixabayImages[index];
            return InkWell(
              onTap: () async {
                shareImage(pixabayImage.webformatURL);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(pixabayImage.previewURL, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pixabayImage.likes.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }
}

class PixabayImage {
  final String previewURL;
  final int likes;
  final String webformatURL;

  PixabayImage({
    required this.previewURL,
    required this.likes,
    required this.webformatURL,
  });

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      previewURL: map['previewURL'],
      likes: map['likes'],
      webformatURL: map['webformatURL'],
    );
  }
}
