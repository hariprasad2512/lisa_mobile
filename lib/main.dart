import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'screens/home_screen.dart';
import 'services/assistant_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  runApp(const LisaApp());
}

class LisaApp extends StatefulWidget {
  const LisaApp({super.key});
  @override
  State<LisaApp> createState() => _LisaAppState();
}

class _LisaAppState extends State<LisaApp> {
  late final AssistantController controller;
  ThemeMode mode = ThemeMode.system;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    controller = AssistantController();
    _boot();
  }

  Future<void> _boot() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(AppConfig.themeKey);
    if (saved == 'light') {
      mode = ThemeMode.light;
    } else if (saved == 'dark') {
      mode = ThemeMode.dark;
    }
    await controller.init();
    if (mounted) setState(() => ready = true);
  }

  Future<void> _toggleTheme() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      if (mode == ThemeMode.dark) {
        mode = ThemeMode.light;
      } else if (mode == ThemeMode.light) {
        mode = ThemeMode.dark;
      } else {
        mode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      }
    });
    await p.setString(
      AppConfig.themeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lisa',
      debugShowCheckedModeBanner: false,
      theme: LisaTheme.light(),
      darkTheme: LisaTheme.dark(),
      themeMode: mode,
      home: ready
          ? HomeScreen(controller: controller, onToggleTheme: _toggleTheme)
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
