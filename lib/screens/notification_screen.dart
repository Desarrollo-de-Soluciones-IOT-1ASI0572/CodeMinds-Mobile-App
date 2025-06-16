import 'package:flutter/material.dart' hide Notification;
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/features/notification/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notification> _notifications = [];

  // userId
  int userId = 1;

  Future<void> _loadData() async {
    List<Notification> notifications = await NotificationRepository(
      notificationService: NotificationService(),
    ).getNotificationsByUserId(userId);

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
    );
  }
}
