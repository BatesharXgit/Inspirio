import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/status/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inspirio/status/common.dart';
import 'package:inspirio/status/models/tab_type.dart';
import 'package:inspirio/status/screens/give_permissions_screen.dart';
import 'package:inspirio/status/services/delete_thumbnails.dart';
import 'package:inspirio/status/widgets/do_or_die.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const numOfTabs = 2;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  String shortcut = 'no action set';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(vsync: this, length: HomeScreen.numOfTabs);
    initQuickActions();
    deleteUnnecessaryThumbnailsIsolate([
      ...ref.read(recentStatusesProvider)?.toList() ?? [],
      ...ref.read(recentStatusesProvider)?.toList() ?? []
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  void initQuickActions() {
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == "action_recent") {
        _tabController.animateTo(0);
      } else if (shortcutType == "action_saved") {
        _tabController.animateTo(1);
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_saved',
        localizedTitle: "Saved",
        icon: 'saved_icon',
      ),
      const ShortcutItem(
        type: 'action_recent',
        localizedTitle: "Recent",
        icon: 'recent_icon',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final storagePermissionStatus = ref.watch(storagePermissionProvider);

    if (storagePermissionStatus == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return (storagePermissionStatus == PermissionStatus.granted)
        ? Scaffold(
            appBar: AppBar(
              title: Text("Status"),
              elevation: 4,
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  MyTab(tabName: "Recent"),
                  MyTab(tabName: "Saved"),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: const [
                DoOrDie(tabType: TabType.recent),
                DoOrDie(tabType: TabType.saved),
              ],
            ),
          )
        : const GivePermissionsScreen();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(recentStatusesProvider.notifier).refresh();
      ref.read(savedStatusesProvider.notifier).refresh();
    }
  }
}

class MyTab extends StatelessWidget {
  final String tabName;
  const MyTab({super.key, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        tabName,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
      ),
    );
  }
}
