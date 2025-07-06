import 'package:codeminds_mobile_application/shared/home_driver_screen.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/map_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:codeminds_mobile_application/notifications/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/notifications/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/notifications/domain/entities/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/tracking_screen.dart';
import 'package:intl/intl.dart';

import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar_driver.dart';

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
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      final String role = prefs.getString('role')!;

      final notifications = await NotificationRepository(
        notificationService: NotificationService(),
      ).getNotificationsByUserId(userId!);

      setState(() {
        _notifications = notifications.reversed.take(_itemsPerPage).toList();
        _role = role;
        _hasMore = notifications.length > _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error loading notifications: ${e.toString()}');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      final notifications = await NotificationRepository(
        notificationService: NotificationService(),
      ).getNotificationsByUserId(userId!);

      final newNotifications = notifications
          .reversed
          .skip(_itemsPerPage * _currentPage)
          .take(_itemsPerPage)
          .toList();

      setState(() {
        _notifications.addAll(newNotifications);
        _currentPage++;
        _hasMore = newNotifications.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error loading more notifications: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with notification count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Recent Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  label: Text(
                    '${_notifications.length}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: colorScheme.primary,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return _buildLoadMoreButton();
                  }

                  final notification = _notifications[index];
                  return _buildNotificationCard(notification, theme);
                },
              ),
            ),
          ),
        ],
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

  Widget _buildNotificationCard(Notification notification, ThemeData theme) {
    final dateFormat = DateFormat('MMM d, y • hh:mm a');
    final isUnread = notification.status == 'UNREAD';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isUnread
          ? theme.colorScheme.primary.withOpacity(0.05)
          : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNotificationDetails(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getNotificationIcon(notification.eventType), // Changed from type to eventType
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getNotificationTitle(notification.eventType), // Changed from type to eventType
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnread
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(notification.timestamp), // Changed from createdAt to timestamp
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No more notifications',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _loadMoreNotifications,
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Load More'),
        ),
      ),
    );
  }

  void _showNotificationDetails(Notification notification) {
    final dateFormat = DateFormat('MMMM d, y • hh:mm a');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getNotificationIcon(notification.eventType), // Changed from type to eventType
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(_getNotificationTitle(notification.eventType)), // Changed from type to eventType
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (notification.description.isNotEmpty)
                  Text(
                    notification.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 16),
                Text(
                  dateFormat.format(notification.timestamp), // Changed from createdAt to timestamp
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String eventType) {
    switch (eventType.toLowerCase()) { // Changed to use eventType
      case 'alert':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'reminder':
        return Icons.notifications;
      case 'update':
        return Icons.system_update;
      case 'trip':
        return Icons.directions_bus;
      case 'student':
        return Icons.school;
      default:
        return Icons.notifications_none;
    }
  }

  String _getNotificationTitle(String eventType) {
    switch (eventType.toLowerCase()) { // Changed to use eventType
      case 'alert':
        return 'Alert';
      case 'info':
        return 'Information';
      case 'reminder':
        return 'Reminder';
      case 'update':
        return 'Update';
      case 'trip':
        return 'Trip Update';
      case 'student':
        return 'Student Update';
      default:
        return eventType; // Return the raw eventType if no match
    }
  }
}