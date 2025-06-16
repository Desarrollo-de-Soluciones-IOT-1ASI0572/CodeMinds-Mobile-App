import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String selectedRoute = 'Route A';

  final Map<String, Map<String, dynamic>> routeData = {
    'Route A': {
      'location': 'Av. Primavera 123',
      'status': 'On the way',
      'distance': '2.4 km',
    },
    'Route B': {
      'location': 'Calle Los Olivos 456',
      'status': 'At school',
      'distance': '5.8 km',
    },
    'Route C': {
      'location': 'Jr. San Martín 789',
      'status': 'At home',
      'distance': '0 km',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo y título "Map"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/CodeMinds-Logo.png',
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Map',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mapa
              SizedBox(
                height: 280,
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

              const SizedBox(height: 16),

              // Información y selector de ruta
              _buildInfoRow(
                'Select Route:',
                DropdownButton<String>(
                  value: selectedRoute,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRoute = newValue!;
                    });
                  },
                  items: routeData.keys.map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                ),
              ),
              _buildInfoRow('Location:', Text(routeData[selectedRoute]!['location'])),
              _buildInfoRow('Status:', Text(routeData[selectedRoute]!['status'])),
              _buildInfoRow('Distance(Km):', Text(routeData[selectedRoute]!['distance'])),

              const SizedBox(height: 12),

              // Botón de emergencia
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Acción de emergencia
                  },
                  child: const Text(
                    'Emergency',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Footer de navegación
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          switch (index) {
            case 0:
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MapScreen()));
              break;
            case 2:
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
              break;
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
}