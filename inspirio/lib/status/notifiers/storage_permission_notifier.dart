import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/services/show_toast.dart';

class StoragePermissionNotifier extends StateNotifier<PermissionStatus?> {
  Permission? _storagePermission;
  bool _tempFirstTime = true;

  StoragePermissionNotifier() : super(null);

  void initialize() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    _storagePermission = androidInfo.version.sdkInt >= 31
        ? Permission.manageExternalStorage
        : Permission.storage;
    state = await _storagePermission?.status;
  }

  PermissionStatus? get status => state;

  void requestAndHandle(BuildContext context) {
    if (_storagePermission == null) return;

    _storagePermission!.request().then((status) async {
      switch (status) {
        case PermissionStatus.granted:
          state = PermissionStatus.granted;
          return;
        case PermissionStatus.denied:
          return;
        case PermissionStatus.permanentlyDenied:
        case PermissionStatus.restricted:
        case PermissionStatus.limited: // do not have idea about limited
          if (_tempFirstTime) {
            _tempFirstTime = false;
            return;
          }
          openAppSettings().then((value) {
            if (value) {
              showToast(
                  message: "Allow storage permission to Save Status",
                  toastLength: Toast.LENGTH_LONG);
            } else {
              showToast(
                  message:
                      "Could not open app settings for storage permission.");
            }
          });
          return;
        case PermissionStatus.provisional:
      }
    });
  }
}
