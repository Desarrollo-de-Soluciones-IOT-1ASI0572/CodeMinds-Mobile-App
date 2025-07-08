import 'package:codeminds_mobile_application/shared/home_driver_screen.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/map_screen.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/tracking_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar_Driver.dart';
import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/profiles/presentation/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codeminds_mobile_application/profiles/presentation/account_update_screen.dart';
import '../domain/entities/profile.dart';
import '../application/services/profile_service.dart';

class AccountScreen extends StatefulWidget {
  final int selectedIndex;
  const AccountScreen({super.key, required this.selectedIndex});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  ProfileModel? profile;
  bool isLoading = true;
  String? error;
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

  Future<void> _onNavTap(int index) async {
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
          final prefs = await SharedPreferences.getInstance();
          final driverId = prefs.getInt('user_id');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MapScreen(driverId: driverId!)),
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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final String role = prefs.getString('role')!;

      if (userId == null) {
        setState(() {
          error = 'No user ID found. Please log in again.';
          isLoading = false;
        });
        return;
      }

      final fetchedProfile = await ProfileService().fetchProfile(userId);
      setState(() {
        profile = fetchedProfile;
        isLoading = false;
        _role = role;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error: $error'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 120),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (profile != null &&
                                profile!.photoUrl.isNotEmpty)
                            ? NetworkImage(profile!.photoUrl)
                            : const AssetImage('assets/images/circle-user.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Name: ${profile?.fullName ?? ''}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Email: ${profile?.email ?? ''}',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Phone Number: ${profile?.mobileNumber ?? ''}',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 16.0),
                      _buildButton('Log Out', Icons.logout, Colors.black, () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }),
                    ],
                  ),
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

  Widget _buildButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
