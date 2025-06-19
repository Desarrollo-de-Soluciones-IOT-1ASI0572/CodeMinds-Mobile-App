import 'package:codeminds_mobile_application/screens/children_screen.dart';
import 'package:codeminds_mobile_application/screens/past_trips_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tracking_screen.dart';
import 'notification_screen.dart';
import 'account_screen.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      HomeScreen(onSeeMoreNotifications: () => _onItemTapped(2)),
      //const TrackingScreen(),
      const PastTripsScreen(),
      const NotificationScreen(),
      const AccountScreen(),
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
