import 'package:flutter/material.dart';

import '../screens/history_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/settings_screen.dart';
import '../state/hydration_state.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_header.dart';

class HydroPulseApp extends StatefulWidget {
  const HydroPulseApp({super.key});

  @override
  State<HydroPulseApp> createState() => _HydroPulseAppState();
}

class _HydroPulseAppState extends State<HydroPulseApp> {
  final HydrationState _state = HydrationState();
  int _selectedTab = 0;

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return MaterialApp(
          title: 'HydroPulse',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: _state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const AppHeader(),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedTab,
                      children: [
                        HomeScreen(state: _state, onOpenSchedule: () => _selectTab(1)),
                        ScheduleScreen(state: _state),
                        HistoryScreen(state: _state),
                        SettingsScreen(state: _state),
                      ],
                    ),
                  ),
                  AppBottomNavigation(
                    selectedIndex: _selectedTab,
                    onSelected: _selectTab,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectTab(int index) => setState(() => _selectedTab = index);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0284C7),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
