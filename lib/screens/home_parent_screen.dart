import 'package:flutter/material.dart' hide Notification;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/features/notification/data/repository/notification_repository.dart';
import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';
import 'package:codeminds_mobile_application/screens/children_screen.dart';


import '../features/tracking/data/remote/trip_service.dart';

class HomeParentScreen extends StatefulWidget {
  final String name;
  final VoidCallback onSeeMoreNotifications;

  const HomeParentScreen({
    super.key,
    this.name = "Default Name",
    required this.onSeeMoreNotifications,
  });

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  final List<String> children = ['Alice', 'Bob', 'Charlie'];
  List<Notification> _notifications = [];
  int id = 1;
  final int _studentId = 16;

  late GoogleMapController _mapController;
  final LatLng _initialPosition = const LatLng(-12.0464, -77.0428);
  final double _initialZoom = 15.0;
  Set<Marker> _markers = {};
  LatLng? _vehicleLocation;
  BitmapDescriptor? _vehicleIcon;

  @override
  void initState() {
    super.initState();
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
      // Si hay error, usa marcador por defecto
      _vehicleIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      debugPrint('Error cargando ícono personalizado: $e');
    }
  }

  Future<void> _loadVehicleLocation() async {
    try {
      final locationData = await TripService().getCurrentVehicleLocation(_studentId);

      if (locationData != null && locationData['location'] != null) {
        final lat = locationData['location']['latitude'] as double;
        final lng = locationData['location']['longitude'] as double;

        setState(() {
          _vehicleLocation = LatLng(lat, lng);
          _markers = {
            Marker(
              markerId: const MarkerId('vehicle_location'),
              position: _vehicleLocation!,
              icon: _vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: const InfoWindow(title: 'Vehículo escolar'),
              rotation: locationData['speed'] != null ? (locationData['speed'] as double) : 0.0,
            ),
          };
        });

        // Mover la cámara a la ubicación
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
    List<Notification> notifications = await NotificationRepository(
      notificationService: NotificationService(),
    ).getNotificationsByUserId(id);

    setState(() {
      _notifications = notifications;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChildrenScreen()),
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
                    child: Text(notification.message),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}