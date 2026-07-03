import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/directory_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/business_portal_screen.dart';
import 'screens/account_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DirectoryProvider()),
      ],
      child: const KawtharDirectoryApp(),
    ),
  );
}

class KawtharDirectoryApp extends StatelessWidget {
  const KawtharDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();

    return MaterialApp(
      title: 'Kawthar Directory',
      debugShowCheckedModeBanner: false,
      themeMode: provider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0F4C3A),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C3A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0F4C3A),
        scaffoldBackgroundColor: const Color(0xFF111827),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C3A),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final isBusinessOwner = provider.currentUser?.role == UserRole.business;
    final isAdmin = provider.currentUser?.role == UserRole.admin;

    final tabs = [
      const HomeScreen(),
      const SearchScreen(),
      if (isBusinessOwner) const BusinessPortalScreen() else const SavedScreen(),
      if (isAdmin) const AdminPanelScreen() else const AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(isBusinessOwner ? LucideIcons.briefcase : LucideIcons.heart),
            label: isBusinessOwner ? 'Business' : 'Saved',
          ),
          NavigationDestination(
            icon: Icon(isAdmin ? LucideIcons.shield : LucideIcons.user),
            label: isAdmin ? 'Admin' : 'Account',
          ),
        ],
      ),
    );
  }
}
