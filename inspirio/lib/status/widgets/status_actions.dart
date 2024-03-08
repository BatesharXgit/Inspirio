import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/providers.dart';
import 'package:inspirio/status/services/show_toast.dart';
import 'package:share_plus/share_plus.dart';

class StatusActions extends ConsumerWidget {
  final String statusPath;
  const StatusActions({super.key, required this.statusPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> actions = [];

    // Insert Save status action
    final String saveStatusPath = getSavedStatusPath(statusPath);
    if (saveStatusPath.compareTo(statusPath) != 0) {
      actions.add(FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          bool exists =
              (ref.read(savedStatusesProvider) ?? []).contains(saveStatusPath);
          if (!exists) {
            await ref.read(savedStatusesProvider.notifier).add(statusPath);
          }
          showToast(getMessage: () => "Saved");
        },
        icon: const Icon(Icons.file_download_rounded),
        label: Text("Save"),
      ));
    }

    actions.addAll([
      // Insert Share status action
      FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          // ignore: deprecated_member_use
          Share.shareFiles([statusPath], subject: 'Whatsapp Status');
        },
        icon: const Icon(Icons.share_rounded),
        label: Text("Share"),
      )
    ]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions,
    );
  }
}

class DeleteAction extends ConsumerWidget {
  final String statusPath;
  final ChewieController? chewieController;
  const DeleteAction(
      {super.key, required this.statusPath, this.chewieController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        bool isVideoPlaying = chewieController?.isPlaying ?? false;
        if (isVideoPlaying) {
          chewieController?.pause();
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Delete Status"),
            content: Text(
              "Delete Status",
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  pop(context);
                  if (isVideoPlaying) {
                    chewieController?.play();
                  }
                },
                child: Text("CANCEL"),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(savedStatusesProvider.notifier)
                      .remove(statusPath)
                      .then(
                    (value) {
                      pop(context);
                      pop(context);
                      showToast(message: "Status deleted");
                      if (isVideoPlaying) {
                        chewieController?.play();
                      }
                    },
                  );
                },
                child: Text("DELETE"),
              ),
            ],
          ),
        );
      },
      icon: const Icon(
        Icons.delete_forever,
        color: Colors.white,
      ),
    );
  }
}
