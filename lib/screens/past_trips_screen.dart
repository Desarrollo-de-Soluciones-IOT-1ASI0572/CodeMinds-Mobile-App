import 'package:codeminds_mobile_application/features/tracking/domain/location.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'trip_map.dart';

class PastTripsScreen extends StatefulWidget {
  const PastTripsScreen({super.key});

  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
  late TripService tripService;
  late Map<int, List<Location>> _tripLocationsCache;

  @override
  void initState() {
    super.initState();
    tripService = TripService();
    _tripLocationsCache = {};
  }

  Future<List<Trip>> _getTrips() async {
    final tripDTOs = await tripService.getAllTrips();
    return tripDTOs.map((dto) => dto.toTrip()).toList();
  }

  Future<List<Location>> _getTripLocations(int tripId) async {
    if (_tripLocationsCache.containsKey(tripId)) {
      return _tripLocationsCache[tripId]!;
    }

    final locations = await tripService.getTripLocations(tripId);
    _tripLocationsCache[tripId] = locations;
    return locations;
  }

  List<LatLng> _convertLocationsToLatLng(List<Location> locations) {
    return locations.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();
  }

  String _calculateAverageDuration(List<Trip> trips) {
    if (trips.isEmpty) return '0 mins';

    final totalDuration = trips.fold(
        Duration.zero,
            (sum, trip) => sum + trip.endTime.difference(trip.startTime)
    );

    final averageInMinutes = totalDuration.inMinutes ~/ trips.length;

    if (averageInMinutes < 60) return '$averageInMinutes mins';

    final hours = averageInMinutes ~/ 60;
    final minutes = averageInMinutes % 60;

    return '${hours}h ${minutes}m';
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

                          // Duración promedio del viaje (dinámica)
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

                          const SizedBox(height: 16),

                          // Botón "Load More"
                          Center(
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
                          ),
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

  Widget _buildTripCard(Trip trip, String formattedDate, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Miniatura del mapa (placeholder)
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
                  Text(
                    "Trip ${trip.id}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Botones de acción
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _editTripName(trip, index),
            ),
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
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip?'),
          content: const Text(
              "This action cannot be undone. The trip data will be permanently deleted."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                bool success = await tripService.deleteTrip(trip.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip deleted successfully'),
                    ),
                  );
                  setState(() {
                    _tripLocationsCache.remove(trip.id);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete trip')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}