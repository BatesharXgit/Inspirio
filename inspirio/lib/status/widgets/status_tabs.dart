import 'package:flutter/material.dart';
import 'package:inspirio/status/models/tab_type.dart';
import 'package:inspirio/status/screens/not_found_screen.dart';
import 'package:inspirio/status/services/is_directory_exists.dart';
import 'package:inspirio/status/widgets/statuses_list.dart';

class DoOrDie extends StatelessWidget {
  final TabType tabType;
  const DoOrDie({
    super.key,
    required this.tabType,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isDirectoryExists(tabType: tabType),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!) {
              return StatusesList(tabType: tabType);
            }
            return NotFoundScreen(
                message: tabType == TabType.recent
                    ? "Whatsapp is not installed on your mobile"
                    : "No saved statuses");
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
