import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspirio/status/providers.dart';
import 'package:inspirio/status/screens/home_screen.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
 
  CorePalette? corePalette = await DynamicColorPlugin.getCorePalette();

  runApp(ProviderScope(child: MyApp(corePalette: corePalette)));
}

class MyApp extends ConsumerWidget {
  final CorePalette? corePalette;
  const MyApp({super.key, this.corePalette});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _preloadRequiredData(ref);
    ColorScheme? lightColorScheme;
    ColorScheme? darkColorScheme;
    if (corePalette != null) {
      lightColorScheme = corePalette?.toColorScheme();
      darkColorScheme = corePalette?.toColorScheme(brightness: Brightness.dark);
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Saver',
      // supportedLocales: AppLocalizations.supportedLocales,

      theme: AppTheme.lightTheme(lightColorScheme),
      darkTheme: AppTheme.darkTheme(darkColorScheme),
      home: const HomeScreen(),
    );
  }

  void _preloadRequiredData(WidgetRef ref) {
    ref.read(storagePermissionProvider.notifier).initialize();
  }
}
