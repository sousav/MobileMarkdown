import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/viewer_screen.dart';
import 'services/share_receiver.dart';

bool get _isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (_isMobile) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  runApp(const MobileMarkdownApp());
}

/// Provides theme state to descendants without prop drilling.
class ThemeController extends InheritedWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;

  const ThemeController({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeController>()!;
  }

  /// Cycles: system -> light -> dark -> system
  void cycleTheme() {
    switch (themeMode) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
    }
  }

  IconData get themeIcon {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String get themeLabel {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System theme';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

class MobileMarkdownApp extends StatefulWidget {
  const MobileMarkdownApp({super.key});

  @override
  State<MobileMarkdownApp> createState() => _MobileMarkdownAppState();
}

class _MobileMarkdownAppState extends State<MobileMarkdownApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final ShareReceiver _shareReceiver = ShareReceiver();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static const _themePrefKey = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    if (_isMobile) {
      _initShareReceiver();
    }
  }

  @override
  void dispose() {
    _shareReceiver.dispose();
    super.dispose();
  }

  void _initShareReceiver() {
    _shareReceiver.init((content, fileName) {
      // Navigate to viewer when a file is received via share/intent
      _navigatorKey.currentState?.pushNamed(
        '/view',
        arguments: {'content': content, 'fileName': fileName},
      );
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themePrefKey);
    if (saved != null && mounted) {
      setState(() {
        _themeMode = _themeModeFromString(saved);
      });
    }
    if (_isMobile) {
      FlutterNativeSplash.remove();
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.name);
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'MobileMarkdown',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/view':
              final args = settings.arguments as Map<String, String?>?;
              return MaterialPageRoute(
                builder: (context) => ViewerScreen(
                  markdownContent: args?['content'] ?? '',
                  fileName: args?['fileName'] ?? 'Untitled',
                  filePath: args?['filePath'],
                  errorMessage: args?['errorMessage'],
                ),
              );
            case '/':
            default:
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
          }
        },
      ),
    );
  }
}
