import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import '../../assignments/domain/entities/student.dart';
import '../../assignments/api/student_service.dart';
import '../data/remote/trip_service.dart';

class TrackingScreen extends StatefulWidget {
  final int selectedIndex;
  const TrackingScreen({super.key, required this.selectedIndex});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<Student> _children = [];
  Student? _selectedChild;
  bool _isLoading = true;
  int _selectedIndex = 0;
  LatLng? _vehiclePosition;
  String _trackingStatus = "No activo";
  double? _currentSpeed;
  bool _isTrackingLoading = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _autoRefresh = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadChildren();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        final children = await StudentService().getStudentsByParentUserId(userId);
        setState(() {
          _children = children;
          _selectedChild = children.isNotEmpty ? children.first : null;
          _isLoading = false;
        });
        if (_selectedChild != null) {
          await _updateVehicleLocation();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error cargando hijos: ${e.toString()}');
    }
  }

  Future<void> _updateVehicleLocation() async {
    if (_selectedChild == null) return;

    setState(() => _isTrackingLoading = true);
    try {
      final locationData = await TripService().getCurrentVehicleLocation(_selectedChild!.id);
      final newPosition = LatLng(
          locationData['location']['latitude'],
          locationData['location']['longitude']
      );

      setState(() {
        _vehiclePosition = newPosition;
        _currentSpeed = locationData['speed'];
        _trackingStatus = "En camino";
        _isTrackingLoading = false;

        _markers = {
          Marker(
            markerId: const MarkerId('vehicle'),
            position: newPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: 'Vehículo escolar',
              snippet: 'Velocidad: ${_currentSpeed?.toStringAsFixed(1) ?? '--'} km/h',
            ),
          )
        };
      });

      // Move camera to new position with appropriate zoom
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 15),
      );
    } catch (e) {
      setState(() {
        _trackingStatus = "Sin viaje activo";
        _vehiclePosition = null;
        _currentSpeed = null;
        _isTrackingLoading = false;
        _markers = {};
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      if (_autoRefresh) {
        _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          _updateVehicleLocation();
        });
      } else {
        _refreshTimer?.cancel();
      }
    });
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
    final userName = prefs.getString('user_name') ?? "Default Name";
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

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        _navigateToHomeParent();
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TrackingScreen(selectedIndex: 1)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento en Tiempo Real'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _updateVehicleLocation,
            tooltip: 'Actualizar ubicación',
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _vehiclePosition ?? const LatLng(51.5, -0.09),
                    zoom: 13.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (_vehiclePosition != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_vehiclePosition!, 15),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          // Info Section
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _children.isEmpty
                  ? Center(
                child: Text(
                  'No se encontraron hijos',
                  style: theme.textTheme.bodyLarge,
                ),
              )
                  : Column(
                children: [
                  // Student Selection
                  _buildInfoCard(
                    'Estudiante',
                    DropdownButtonFormField<Student>(
                      value: _selectedChild,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (Student? newValue) {
                        setState(() => _selectedChild = newValue);
                        _updateVehicleLocation();
                      },
                      items: _children.map<DropdownMenuItem<Student>>((child) {
                        return DropdownMenuItem<Student>(
                          value: child,
                          child: Text(
                            '${child.name} ${child.lastName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  if (_selectedChild != null) ...[
                    // Address Info
                    _buildInfoCard(
                      'Dirección',
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_selectedChild!.homeAddress),
                          ),
                        ],
                      ),
                    ),

                    // School Info
                    _buildInfoCard(
                      'Colegio',
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_selectedChild!.schoolAddress),
                          ),
                        ],
                      ),
                    ),

                    // Status and Speed
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Estado',
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: _trackingStatus == "En camino"
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(_trackingStatus),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Velocidad',
                            Row(
                              children: [
                                Icon(
                                  Icons.speed,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isTrackingLoading
                                      ? 'Cargando...'
                                      : '${_currentSpeed?.toStringAsFixed(1) ?? '--'} km/h',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Auto Refresh Toggle
                    SwitchListTile(
                      title: const Text('Actualización automática'),
                      value: _autoRefresh,
                      onChanged: (value) => _toggleAutoRefresh(),
                      secondary: Icon(
                        Icons.autorenew,
                        color: _autoRefresh
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}