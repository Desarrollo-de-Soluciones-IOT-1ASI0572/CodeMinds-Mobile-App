import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codeminds_mobile_application/features/student/data/remote/student.dart';
import 'package:codeminds_mobile_application/features/student/data/remote/student_service.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/screens/home_parent_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar.dart';

class TrackingScreen extends StatefulWidget {
  final int selectedIndex;
  const TrackingScreen({super.key, required this.selectedIndex});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<StudentModel> _children = [];
  StudentModel? _selectedChild;
  bool _isLoading = true;
  int _selectedIndex = 0;
  LatLng? _vehiclePosition;
  String _trackingStatus = "No activo";
  double? _currentSpeed;
  bool _isTrackingLoading = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadChildren();
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
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando hijos: ${e.toString()}'))
      );
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
            infoWindow: const InfoWindow(title: 'Vehículo escolar'),
          )
        };
      });

      // Mover la cámara a la nueva posición
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newPosition),
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
            MaterialPageRoute(builder: (context) => const TrackingScreen(selectedIndex: 1))
        );
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen(selectedIndex: 2))
        );
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AccountScreen(selectedIndex: 3))
        );
        break;
    }
  }

  Widget buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(
                  label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              )
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5),
              ),
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset(
                    'assets/images/CodeMinds-Logo.png',
                    height: 50,
                    width: 50
                ),
                const SizedBox(width: 10),
                const Text(
                    'Tracking',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: GoogleMap(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _children.isEmpty
                ? const Text('No se encontraron hijos')
                : Column(
              children: [
                buildInfoRow(
                  'Hijo:',
                  DropdownButton<StudentModel>(
                    value: _selectedChild,
                    onChanged: (StudentModel? newValue) {
                      setState(() => _selectedChild = newValue);
                      _updateVehicleLocation();
                    },
                    items: _children.map<DropdownMenuItem<StudentModel>>((child) {
                      return DropdownMenuItem<StudentModel>(
                        value: child,
                        child: Text('${child.name} ${child.lastName}'),
                      );
                    }).toList(),
                  ),
                ),
                if (_selectedChild != null) ...[
                  buildInfoRow(
                      'Dirección:',
                      Text(_selectedChild!.homeAddress)
                  ),
                  buildInfoRow(
                      'Colegio:',
                      Text(_selectedChild!.schoolAddress)
                  ),
                  buildInfoRow(
                      'Estado:',
                      Text(_trackingStatus)
                  ),
                  buildInfoRow(
                      'Velocidad:',
                      Text(_isTrackingLoading
                          ? 'Cargando...'
                          : '${_currentSpeed?.toStringAsFixed(1) ?? '--'} km/h')
                  ),
                ],
              ],
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