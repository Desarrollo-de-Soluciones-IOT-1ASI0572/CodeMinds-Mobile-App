import 'package:codeminds_mobile_application/assignments/presentation/children_screen.dart';
import 'package:flutter/material.dart';
import 'home_parent_screen.dart';
import '../tracking/presentation/tracking_screen.dart';
import 'notification_screen.dart';
import '../profiles/presentation/account_screen.dart';
import 'widgets/custom_bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  final String token; // Agrega el parámetro token

  const MainScreen({super.key, required this.token}); // Constructor con token

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeParentScreen(
          onSeeMoreNotifications: () => _onItemTapped(2), selectedIndex: 0),
      const TrackingScreen(selectedIndex: 1),
      const NotificationScreen(selectedIndex: 2),
      const AccountScreen(selectedIndex: 3),
      const ChildrenScreen()
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
