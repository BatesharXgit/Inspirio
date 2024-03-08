import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/widgets/status_actions.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoPath;
  final double height;
  final double width;
  const VideoView(
      {super.key,
      required this.videoPath,
      required this.height,
      required this.width});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late final ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
        videoPlayerController:
            VideoPlayerController.file(File(widget.videoPath)),
        autoInitialize: true,
        autoPlay: true,
        showOptions: false,
        aspectRatio: widget.width / widget.height,
        errorBuilder: (_, errorMessage) {
          return Text(errorMessage);
        });
  }

  @override
  void dispose() {
    _chewieController!.pause();
    _chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          if (isItSavedStatus(widget.videoPath))
            DeleteAction(
              statusPath: widget.videoPath,
              chewieController: _chewieController,
            )
        ],
        leading: TextButton(
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => pop(context),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Hero(
            tag: widget.videoPath,
            child: Chewie(
              controller: _chewieController!,
            ),
          ),
          Positioned(
            bottom: 33,
            right: 10,
            height: MediaQuery.of(context).size.height * 0.2,
            child: StatusActions(
              statusPath: widget.videoPath,
            ),
          ),
        ],
      ),
    );
  }
}
