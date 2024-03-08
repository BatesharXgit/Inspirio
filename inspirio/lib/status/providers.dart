
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/tab_type.dart';
import 'notifiers/statuses_notifier.dart';
import 'notifiers/storage_permission_notifier.dart';
 

final storagePermissionProvider =
    StateNotifierProvider<StoragePermissionNotifier, PermissionStatus?>(
        (ref) => StoragePermissionNotifier());

final recentStatusesProvider =
    StateNotifierProvider<StatusesNotifier, List<String>?>(
        (ref) => StatusesNotifier(TabType.recent));

final savedStatusesProvider =
    StateNotifierProvider<StatusesNotifier, List<String>?>(
        (ref) => StatusesNotifier(TabType.saved));

