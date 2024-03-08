import 'dart:io';

import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/models/tab_type.dart';

Future<bool> isDirectoryExists({required TabType tabType}) async {
  final List<String> directoryPaths = getDirectoryPaths(tabType);

  for (String directoryPath in directoryPaths) {
    bool isDirExists = await Directory(directoryPath).exists();
    if (isDirExists) return true;
  }
  return false;
}
