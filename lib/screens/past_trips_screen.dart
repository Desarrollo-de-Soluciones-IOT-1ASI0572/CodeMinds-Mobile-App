import 'package:flutter/material.dart';
// import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';

class PastTripsScreen extends StatelessWidget {
  const PastTripsScreen({super.key});

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
              const SizedBox(height: 16),

              // Lista de viajes
              Expanded(
                child: FutureBuilder<List<Trip>>(
                  future: _getTrips(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading trips.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No trips available.'));
                    } else {
                      final trips = snapshot.data!;
                      final averageDuration = _calculateAverageDuration(trips);

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                final trip = trips[index];
                                final formattedDate = DateFormat('MMMM d, y').format(trip.startTime);
                                return _buildTripCard(trip, formattedDate, index);
                              },
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Average Trip Duration: $averageDuration',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Botón "Load More"
                          /*Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 32
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Load More',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),*/
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
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
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.map, size: 40, color: Colors.grey),
                ),
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
              onPressed: () => _showTripInfoDialog(context, trip),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context, trip),
            ),
          ],
        ),
      ),
    );
  }

  void _editTripName(Trip trip, int index) {
    final TextEditingController _titleController = TextEditingController(
      text: "Trip ${trip.id}"
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Trip Name'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Trip Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Lógica para guardar el nuevo nombre
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTripInfoDialog(BuildContext context, Trip trip) async {
    final DateFormat timeFormat = DateFormat.jm();
    final DateFormat dateFormat = DateFormat('MMMM d, y');
    final locations = await _getTripLocations(trip.id);
    final routeCoordinates = _convertLocationsToLatLng(locations);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trip Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('Date:', dateFormat.format(trip.startTime)),
                _buildInfoRow('Start Time:', timeFormat.format(trip.startTime)),
                _buildInfoRow('Start Location:', trip.origin),
                _buildInfoRow('End Time:', timeFormat.format(trip.endTime)),
                _buildInfoRow('End Location:', trip.destination),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: TripMap(routeCoordinates: routeCoordinates),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}