import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inspirio/status/screens/image_view.dart';


class ImageTile extends StatelessWidget {
  const ImageTile({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ImageView(
                  imagePath: imagePath,
                );
              },
            ),
          );
        },
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
