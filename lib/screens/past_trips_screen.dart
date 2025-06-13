import 'package:flutter/material.dart';
// import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';

class PastTripsScreen extends StatelessWidget {
  const PastTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de los viajes anteriores
    final List<Map<String, dynamic>> pastTrips = [
      {
        'date': 'June 10, 2025',
        'duration': '45 mins',
        'mapImage': 'assets/images/PTrip1.png',
      },
      {
        'date': 'June 8, 2025',
        'duration': '40 mins',
        'mapImage': 'assets/images/PTrip2.png',
      },
      {
        'date': 'June 5, 2025',
        'duration': '50 mins',
        'mapImage': 'assets/images/PTrip3.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección del logo y título "Past Trips"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/CodeMinds-Logo.png', // Ruta del logo
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Past Trips',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de viajes anteriores
              Expanded(
                child: ListView.builder(
                  itemCount: pastTrips.length,
                  itemBuilder: (context, index) {
                    final trip = pastTrips[index];
                    return _buildTripCard(trip['date'], trip['duration'], trip['mapImage']);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Duración promedio del viaje
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Average Trip Duration: 45 mins',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // Botón "Load More"
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Acción para cargar más viajes
                  },
                  child: const Text(
                    'Load More',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Footer de navegación (manteniendo el código anterior)
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrackingScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationParentScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
              break;
          }
        },
      ),
    );
  }

  Widget _buildTripCard(String date, String duration, String mapImage) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Miniatura del mapa
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                mapImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Información del viaje
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Duration: $duration', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),

            // Iconos de acciones
            IconButton(
              icon: const Icon(Icons.info, color: Colors.blue),
              onPressed: () {
                // Acción de ver detalles
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Acción de eliminar viaje
              },
            ),
          ],
        ),
      ),
    );
  }
}