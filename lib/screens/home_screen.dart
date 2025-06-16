import 'package:flutter/material.dart';
import 'past_trips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPastTrips = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showPastTrips ? 'Past Trips' : 'Home'),
        leading: _showPastTrips
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _showPastTrips = false);
                },
              )
            : null,
      ),
      body: _showPastTrips
          ? const PastTripsScreen()
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _showPastTrips = true);
                },
                child: const Text('Ver viajes pasados'),
              ),
            ),
    );
  }
}
