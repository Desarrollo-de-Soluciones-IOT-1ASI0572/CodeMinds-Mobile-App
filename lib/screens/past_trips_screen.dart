import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/trip.dart';

class PastTripsScreen extends StatefulWidget {
  const PastTripsScreen({super.key});

  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
  late TripService tripService;

  @override
  void initState() {
    super.initState();
    tripService = TripService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Trips')),
      body: FutureBuilder<List<Trip>>(
        future: _getTrips(), // Convierte los DTO a Trip
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading trips.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trips available.'));
          } else {
            final trips = snapshot.data!;

            return ListView.separated(
              itemCount: trips.length,
              separatorBuilder: (_, __) =>
                  const Divider(thickness: 1, color: Colors.lightBlueAccent),
              itemBuilder: (context, index) {
                final trip = trips[index];
                final formattedDate =
                    "${_monthName(trip.startTime.month)}, ${trip.startTime.day}";

                return ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          // TODO: lógica para cambiar nombre
                        },
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Imagen (puedes reemplazar con un mapa real si tienes URL)
                        Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/map_placeholder.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 28),
                          onPressed: () {
                            _showTripInfoDialog(context, trip);
                          },
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 28,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, trip);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Método para convertir los TripDTO a Trip
  Future<List<Trip>> _getTrips() async {
    final tripDTOs = await tripService.getAllTrips();
    return tripDTOs.map((dto) => dto.toTrip()).toList();
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  void _showTripInfoDialog(BuildContext context, Trip trip) {
    final DateFormat timeFormat = DateFormat.jm();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trip Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Date:',
                  "${_monthName(trip.startTime.month)} ${trip.startTime.day}",
                ),
                _buildInfoRow(
                  'Starting Hour:',
                  timeFormat.format(trip.startTime),
                ),
                _buildInfoRow('Starting Address:', trip.origin),
                _buildInfoRow(
                  'Finishing Hour:',
                  timeFormat.format(trip.endTime),
                ),
                _buildInfoRow('Finishing Address:', trip.destination),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure you want to delete this trip?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "You won't be able to see this trip again once you delete it.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Eliminar el viaje
                bool success = await tripService.deleteTrip(trip.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip deleted successfully')),
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete the trip')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
