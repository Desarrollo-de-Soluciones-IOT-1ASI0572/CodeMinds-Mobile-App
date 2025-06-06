import 'package:flutter/material.dart' hide Notification;
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/features/notification/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final VoidCallback onSeeMoreNotifications;

  HomeScreen({
    super.key,
    this.name = "Default Name",
    required this.onSeeMoreNotifications,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> children = ['Alice', 'Bob', 'Charlie'];

  List<Notification> _notifications = [];

  int id = 1;

  Future<void> _loadData() async {
    List<Notification> notifications = await NotificationRepository(
      notificationService: NotificationService(),
    ).getNotificationsByUserId(id);

    setState(() {
      _notifications = notifications;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo y texto de bienvenida
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/CodeMinds-Logo.png',
                      height: 70,
                      width: 70,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Welcome again!\n${widget.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Placeholder del mapa
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text(
                      'Map Placeholder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de hijos
                const Text(
                  'Children',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: children.take(2).map((childName) {
                          return Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.cyan[100],
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  childName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: 25),

                // Sección de notificaciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          widget.onSeeMoreNotifications, // 👈 Llama al callback
                      child: const Text('See More'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(
                  children: _notifications.isEmpty
                      ? [const Center(child: CircularProgressIndicator())]
                      : _notifications.take(2).map((notification) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Text(
                              notification.message,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
