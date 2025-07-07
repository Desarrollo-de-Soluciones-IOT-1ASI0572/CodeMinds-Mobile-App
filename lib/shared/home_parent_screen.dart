import 'package:codeminds_mobile_application/assignments/domain/entities/student.dart';
import 'package:codeminds_mobile_application/assignments/application/services/student_service.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/tracking_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:codeminds_mobile_application/notifications/infrastructure/repositories/notification_repository.dart';
import 'package:codeminds_mobile_application/notifications/domain/entities/notification.dart';
import 'package:codeminds_mobile_application/assignments/presentation/children_screen.dart';
import '../notifications/application/services/notification_service.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeParentScreen extends StatefulWidget {
  final String name;
  final VoidCallback onSeeMoreNotifications;
  final int selectedIndex;

  const HomeParentScreen({
    super.key,
    this.name = "parent", // Default changed to match your image
    required this.onSeeMoreNotifications,
    required this.selectedIndex,
  });

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  List<Student> _children = [];
  List<Notification> _notifications = [];
  bool _isLoading = true;

  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeParentScreen(
                  name: widget.name,
                  onSeeMoreNotifications: widget.onSeeMoreNotifications,
                  selectedIndex: 0)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TrackingScreen(selectedIndex: 1)),
        );
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

    try {
      final notifications = await NotificationRepository(
        notificationService: NotificationService(),
      ).getNotificationsByUserId(userId!);

      // Ordenar notificaciones por fecha (más recientes primero)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final children = await StudentService().getStudentsByParentUserId(userId);

      setState(() {
        _notifications = notifications;
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading data")),
      );
    }
  }

  Widget _buildChildCard(Student student) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.cyan[100],
              backgroundImage: student.studentPhotoUrl != null &&
                  student.studentPhotoUrl.isNotEmpty
                  ? NetworkImage(student.studentPhotoUrl)
                  : const AssetImage('assets/images/circle-user.png')
              as ImageProvider,
              child: student.studentPhotoUrl == null ||
                  student.studentPhotoUrl.isEmpty
                  ? const Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              '${student.name} ${student.lastName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.message,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header (centered)
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/CodeMinds-Logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome again,',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Children Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Children',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChildrenScreen()),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Children Grid
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: _children
                      .take(2)
                      .map((child) => _buildChildCard(child))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Notifications Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSeeMoreNotifications,
                      child: const Text('See More'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Notifications List
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _notifications.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : Column(
                  children: _notifications
                      .take(2)
                      .map((n) => _buildNotificationItem(n))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}