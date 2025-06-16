//import 'package:codeminds_mobile_application/screens/map_screen.dart';
import 'package:flutter/material.dart';
//import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar_driver.dart';

class PastTripsScreen extends StatefulWidget {
  const PastTripsScreen({super.key});

  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
  final List<Map<String, dynamic>> pastTrips = [
    {
      'date': 'June 10, 2025',
      'title': 'School Pickup',
      'startTime': '08:00 AM',
      'startLocation': 'Av. Primavera 123',
      'endTime': '08:45 AM',
      'endLocation': 'School A',
      'attendance': '15 Students',
      'mapImage': 'assets/images/PTrip1.png',
    },
    {
      'date': 'June 8, 2025',
      'title': 'Afternoon Drop-off',
      'startTime': '04:00 PM',
      'startLocation': 'School B',
      'endTime': '04:40 PM',
      'endLocation': 'Av. Los Robles 456',
      'attendance': '12 Students',
      'mapImage': 'assets/images/PTrip2.png',
    },
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverScreen()));
        break;
      case 1:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MapScreen()));
        break;
      case 2:
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    return _buildTripCard(trip, index);
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
                  onPressed: () {},
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

      // **Footer de navegación exclusivo para conductores**
      bottomNavigationBar: CustomBottomNavigationBarDriver(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, int index) {
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
                trip['mapImage'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(trip['date'], style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.info, color: Colors.blue),
              onPressed: () => _showTripDetails(trip),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  pastTrips.removeAt(index);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditTripTitle(trip, index),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(trip['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${trip['date']}'),
              Text('Start Time: ${trip['startTime']}'),
              Text('Start Location: ${trip['startLocation']}'),
              Text('End Time: ${trip['endTime']}'),
              Text('End Location: ${trip['endLocation']}'),
              Text('Attendance: ${trip['attendance']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTripTitle(Map<String, dynamic> trip, int index) {
    final TextEditingController _titleController = TextEditingController(text: trip['title']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Trip Name'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'New Trip Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pastTrips[index]['title'] = _titleController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}