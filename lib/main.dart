import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:receptions_app/authentication/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage
      .init(); // Ensure GetStorage is initialized before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Receptions',
      theme: ThemeData.light(), // Default to light theme
      darkTheme: ThemeData.dark(), // Define dark theme
      themeMode: ThemeService().theme, // Theme mode managed by GetX
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// Theme Service to handle light and dark mode
class ThemeService {
  final _getStorage = GetStorage();
  final _darkThemeKey = 'isDarkMode';

  // Load theme from local storage or default to light
  ThemeMode get theme => isDarkMode() ? ThemeMode.dark : ThemeMode.light;

  // Save selected theme mode in local storage
  void switchTheme() {
    Get.changeThemeMode(isDarkMode() ? ThemeMode.light : ThemeMode.dark);
    _getStorage.write(_darkThemeKey, !isDarkMode());
  }

  // Check if dark mode is enabled
  bool isDarkMode() {
    return _getStorage.read(_darkThemeKey) ?? false;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              ThemeService().switchTheme(); // Toggle theme on button press
            },
          ),
        ],
      ),
      body: const LoginPage(),
    );
  }
}
