import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String selectedKid = 'Juan Pérez';

  final Map<String, Map<String, dynamic>> kidData = {
    'Juan Pérez': {
      'location': 'Av. Primavera 123',
      'status': 'En camino',
      'distance': '2.4 km',
      'speed': '15 km/h',
    },
    'María López': {
      'location': 'Calle Los Olivos 456',
      'status': 'En casa',
      'distance': '0 km',
      'speed': '0 km/h',
    },
    'Carlos Gómez': {
      'location': 'Jr. San Martín 789',
      'status': 'En la escuela',
      'distance': '5.8 km',
      'speed': '20 km/h',
    },
  };

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
                  width: 50,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

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

          // Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildInfoRow(
                  'Select Kid:',
                  DropdownButton<String>(
                    value: selectedKid,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedKid = newValue!;
                      });
                    },
                    items: kidData.keys.map<DropdownMenuItem<String>>((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key),
                      );
                    }).toList(),
                  ),
                ),
                buildInfoRow('Location:', Text(kidData[selectedKid]!['location'])),
                buildInfoRow('Status:', Text(kidData[selectedKid]!['status'])),
                buildInfoRow('Distance(Km):', Text(kidData[selectedKid]!['distance'])),
                buildInfoRow('Speed(km/h):', Text(kidData[selectedKid]!['speed'])),
              ],
            ),
          ),
        ],
      ),
    );
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
