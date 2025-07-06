import 'package:codeminds_mobile_application/assignments/domain/entities/student.dart';
import 'package:codeminds_mobile_application/assignments/api/student_service.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/tracking_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:codeminds_mobile_application/notifications/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/notifications/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/notifications/domain/entities/notification.dart';
import 'package:codeminds_mobile_application/assignments/presentation/children_screen.dart';
import '../tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeParentScreen extends StatefulWidget {
  final String name;
  final VoidCallback onSeeMoreNotifications;
  final int selectedIndex;

  const HomeParentScreen({
    super.key,
    this.name = "Default Name",
    required this.onSeeMoreNotifications,
    required this.selectedIndex,
  });

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  List<Student> _children = [];
  List<Notification> _notifications = [];
  final int _studentId = 16;

  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(-12.0464, -77.0428);
  final double _initialZoom = 15.0;
  Set<Marker> _markers = {};
  LatLng? _vehicleLocation;
  BitmapDescriptor? _vehicleIcon;

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
    _loadCustomMarker();
    _loadVehicleLocation();
  }

  Future<void> _loadCustomMarker() async {
    try {
      _vehicleIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(12, 12)),
        'assets/icons/bus_marker_2.png',
      );
    } catch (e) {
      _vehicleIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      debugPrint('Error cargando ícono personalizado: $e');
    }
  }

  Future<void> _loadVehicleLocation() async {
    try {
      final locationData =
          await TripService().getCurrentVehicleLocation(_studentId);

      if (locationData != null && locationData['location'] != null) {
        final lat = locationData['location']['latitude'] as double;
        final lng = locationData['location']['longitude'] as double;

        setState(() {
          _vehicleLocation = LatLng(lat, lng);
          _markers = {
            Marker(
              markerId: const MarkerId('vehicle_location'),
              position: _vehicleLocation!,
              icon: _vehicleIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Vehículo escolar'),
              rotation: locationData['speed'] != null
                  ? (locationData['speed'] as double)
                  : 0.0,
            ),
          };
        });

        if (_mapController != null) {
          _mapController.animateCamera(
            CameraUpdate.newLatLng(_vehicleLocation!),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al cargar ubicación: $e');
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    List<Notification> notifications = await NotificationRepository(
      notificationService: NotificationService(),
    ).getNotificationsByUserId(userId!);

    List<Student> children =
        await StudentService().getStudentsByParentUserId(userId);

    setState(() {
      _notifications = notifications;
      _children = children;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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
                          color: Colors.black, // Color de texto oscuro
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Mapa con ubicación del vehículo
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_vehicleLocation != null) {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLng(_vehicleLocation!),
                            );
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: _vehicleLocation ?? _initialPosition,
                          zoom: _initialZoom,
                        ),
                        markers: _markers,
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: FloatingActionButton.small(
                          onPressed: _loadVehicleLocation,
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de Children
                const Text(
                  'Children',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Color de texto oscuro
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: _children.take(2).map((student) {
                          return Expanded(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.cyan[100],
                                  backgroundImage: student.studentPhotoUrl !=
                                              null &&
                                          student.studentPhotoUrl.isNotEmpty
                                      ? NetworkImage(student.studentPhotoUrl)
                                      : const AssetImage(
                                              'assets/images/circle-user.png')
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
                                const SizedBox(height: 6),
                                Text(
                                  '${student.name} ${student.lastName}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Colors.black, // Color de texto oscuro
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChildrenScreen()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Notificaciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Color de texto oscuro
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
                              style: const TextStyle(
                                color: Colors.black, // Color de texto oscuro
                              ),
                            ),
                          );
                        }).toList(),
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
