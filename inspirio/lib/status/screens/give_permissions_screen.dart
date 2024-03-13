import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/providers.dart';

class GivePermissionsScreen extends ConsumerWidget {
  const GivePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storagePermissionNotifier =
        ref.watch(storagePermissionProvider.notifier);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Give storage permission",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            ElevatedButton(
              child: const Text("Give storage permission"),
              onPressed: () {
                storagePermissionNotifier.requestAndHandle(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
