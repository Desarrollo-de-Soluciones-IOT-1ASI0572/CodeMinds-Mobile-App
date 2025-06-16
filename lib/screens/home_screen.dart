import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
//import 'package:codeminds_mobile_application/features/notification/data/repository/notification_repository.dart';
//import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';
//import 'package:codeminds_mobile_application/screens/children_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final VoidCallback onSeeMoreNotifications;

  const HomeScreen({
    super.key,
    this.name = "Default Name",
    required this.onSeeMoreNotifications,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> children = ['Alice', 'Bob', 'Charlie'];
  //List<Notification> _notifications = [];
  int id = 1;

  Future<void> _loadData() async {
    //List<Notification> notifications = await NotificationRepository(
      //notificationService: NotificationService(),
    //).getNotificationsByUserId(id);

    setState(() {
      //_notifications = notifications;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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

              // **Mapa de TrackingScreen**
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(51.5, -0.09),
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                              Text(childName),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => const ChildrenScreen()),
                      // );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 25),

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
                    onPressed: widget.onSeeMoreNotifications,
                    child: const Text('See More'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Column(
                // children: _notifications.isEmpty
                //     ? [const Center(child: CircularProgressIndicator())]
                //     : _notifications.take(2).map((notification) {
                //   return Container(
                //     width: double.infinity,
                //     margin: const EdgeInsets.only(bottom: 8),
                //     padding: const EdgeInsets.symmetric(
                //       vertical: 12,
                //       horizontal: 16,
                //     ),
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.black26),
                //       borderRadius: BorderRadius.circular(12),
                //       color: Colors.white,
                //     ),
                //     child: Text(notification.message),
                //   );
                // }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}