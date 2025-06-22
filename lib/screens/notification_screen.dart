import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/home_parent_screen.dart';
import 'package:codeminds_mobile_application/screens/map_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar_driver.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/features/notification/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';

class NotificationScreen extends StatefulWidget {
  final int selectedIndex;
  const NotificationScreen({super.key, required this.selectedIndex});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notification> _notifications = [];

  String _role = "";

  int _selectedIndex = 0;

  void _navigateToHomeParent() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Default Name";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeParentScreen(
          name: userName,
          onSeeMoreNotifications: () {},
          selectedIndex: 0,
        ),
      ),
    );
  }

  void _navigateToHomeDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Default Name";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomeDriverScreen(name: userName, selectedIndex: 0),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        if (_role == "ROLE_PARENT") {
          _navigateToHomeParent();
        } else if (_role == "ROLE_DRIVER") {
          _navigateToHomeDriver();
        }
        break;
      case 1:
        if (_role == "ROLE_PARENT") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const TrackingScreen(selectedIndex: 1)),
          );
        } else if (_role == "ROLE_DRIVER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    final String role = prefs.getString('role')!;

    List<Notification> notifications = await NotificationRepository(
      notificationService: NotificationService(),
    ).getNotificationsByUserId(userId!);

    setState(() {
      _notifications = notifications;
      _role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              final backgroundColor = index % 2 == 0
                  ? Colors.grey.shade300
                  : Colors.lightBlue.shade100;

              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 8.0,
                ),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: Colors.black54, width: 0.5),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  notification.message,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _role == "ROLE_PARENT"
          ? CustomBottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavTap,
            )
          : _role == "ROLE_DRIVER"
              ? CustomBottomNavigationBarDriver(
                  currentIndex: _selectedIndex,
                  onTap: _onNavTap,
                )
              : null,
    );
  }
}
