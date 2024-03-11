import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inspirio/authentication/auth%20pages/auth_page.dart';
import 'package:inspirio/home.dart';
import 'package:inspirio/pages/homepage.dart';
import 'package:inspirio/status/providers.dart';
import 'package:inspirio/themes/theme.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  await preloadData();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> preloadData() async {
  const inspirioHome = InspirioHome();
  await inspirioHome.initializeData();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _preloadRequiredData(ref);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: kLightTheme,
      darkTheme: kAmoledTheme,
      // home: const HomePage(),
      home: const AuthPage(),
    );
  }

  void _preloadRequiredData(WidgetRef ref) {
    ref.read(storagePermissionProvider.notifier).initialize();
  }
}
