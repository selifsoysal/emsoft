import 'package:emsoft/core/config/app_config.dart';
import 'package:emsoft/core/theme/app_theme.dart';
import 'package:emsoft/features/browser/presentation/pages/browser_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmsoftApp extends StatelessWidget {
  const EmsoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BrowserPage(),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    AppTheme.light.appBarTheme.systemOverlayStyle!,
  );
}
