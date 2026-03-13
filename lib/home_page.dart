import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'alerts_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardPage(),
    const AlertsPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2F9E44);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: Colors.transparent,
          indicatorColor: primaryGreen.withValues(alpha: 0.12),
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: primaryGreen),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon:
                  Icon(Icons.notifications_active, color: primaryGreen),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: primaryGreen),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: primaryGreen),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}