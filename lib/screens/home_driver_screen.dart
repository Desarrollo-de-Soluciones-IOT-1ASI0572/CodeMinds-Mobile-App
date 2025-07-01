import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/past_trips_screen.dart';
import 'package:codeminds_mobile_application/screens/attendance_screen.dart';
import 'package:codeminds_mobile_application/screens/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/tracking/data/remote/trip_service.dart';
import '../widgets/custom_bottom_navigation_bar_Driver.dart';

class HomeDriverScreen extends StatefulWidget {
  final String name;
  final int selectedIndex;

  const HomeDriverScreen(
      {super.key, required this.name, required this.selectedIndex});

  @override
  State<HomeDriverScreen> createState() => _HomeDriverScreenState();
}

class _HomeDriverScreenState extends State<HomeDriverScreen> {
  int _selectedIndex = 0;
  int? _currentTripId;
  bool _tripStarted = false;

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
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

  void _showCreateTripDialog(BuildContext context) {
    final TextEditingController originController = TextEditingController();
    final TextEditingController destinationController = TextEditingController();
    final tripService = TripService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Viaje"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: originController,
              decoration: const InputDecoration(labelText: "Origen (ej: Colegio)"),
            ),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(labelText: "Destino (ej: Urbanización)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (originController.text.isEmpty || destinationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Ingresa origen y destino!")),
                );
                return;
              }
              Navigator.pop(context);

              final prefs = await SharedPreferences.getInstance();
              final driverId = prefs.getInt('user_id');
              if (driverId == null) return;

              final tripId = await tripService.createTrip(
                vehicleId: driverId,
                driverId: driverId,
                origin: originController.text,
                destination: destinationController.text,
              );

              if (tripId != null) {
                setState(() {
                  _currentTripId = tripId;
                  _tripStarted = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("¡Viaje creado (ID: $tripId)!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error al crear el viaje")),
                );
              }
            },
            child: const Text("Crear Viaje"),
          ),
        ],
      ),
    );
  }

  Future<void> _startTrip() async {
    if (_currentTripId == null) return;

    final success = await TripService().startTrip(_currentTripId!);
    if (success) {
      setState(() {
        _tripStarted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Viaje iniciado!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar viaje")),
      );
    }
  }

  Future<void> _endTrip() async {
    if (_currentTripId == null) return;

    final success = await TripService().endTrip(_currentTripId!);
    if (success) {
      setState(() {
        _tripStarted = false;
        _currentTripId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Viaje finalizado!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al finalizar viaje")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTripDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Crear Viaje',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/CodeMinds-Logo.png',
                      height: 70,
                      width: 70,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome Again!\n${widget.name}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          'assets/images/EmergencyButton.png',
                          height: 100,
                          width: 100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Emergency Button',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Past Trips',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PastTripsScreen()),
                            );
                          },
                          child: Image.asset(
                            'assets/images/PastTrips.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Attendance',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AttendanceScreen(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/images/Attendace.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(-12.0906, -77.0220),
                      zoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(-12.0906, -77.0220),
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_currentTripId != null && !_tripStarted)
                  ElevatedButton(
                    onPressed: _startTrip,
                    child: const Text("Iniciar Viaje"),
                  ),
                if (_currentTripId != null && _tripStarted)
                  ElevatedButton(
                    onPressed: _endTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Terminar Viaje"),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBarDriver(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}