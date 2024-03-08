import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inspirio/status/models/video_thumbnail.dart';
import 'package:inspirio/status/screens/video_view.dart';
import 'package:inspirio/status/services/get_video_thumbnail.dart';
import 'package:inspirio/status/theme/colors.dart';


class VideoTile extends StatelessWidget {
  final String videoPath;
  const VideoTile({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoThumbnail>(
      future: getVideoThumbnail(videoPath),
      builder: ((_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Card(
            elevation: 5,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideoView(
                    videoPath: videoPath,
                    height: snapshot.data!.videoHeight,
                    width: snapshot.data!.videoWidth,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: videoPath,
                    child: Image.file(
                      File(snapshot.data!.path),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                    ),
                  ),
                  const Positioned.fill(
                      child: Center(
                          child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 55,
                    color: videoPlayIconColor,
                  )))
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
