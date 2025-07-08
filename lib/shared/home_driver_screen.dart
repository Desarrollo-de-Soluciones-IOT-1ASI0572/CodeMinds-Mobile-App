import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/past_trips_screen.dart';
import 'package:codeminds_mobile_application/assignments/presentation/attendance_screen.dart';
import 'package:codeminds_mobile_application/tracking/presentation/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tracking/application/services/trip_service.dart';
import '../tracking/infrastructure/data_sources/trip_provider.dart';
import 'widgets/custom_bottom_navigation_bar_Driver.dart';

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
  late TripProvider _tripProvider;
  int? _currentDriverId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDriverId = prefs.getInt('user_id');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tripProvider = Provider.of<TripProvider>(context);
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        if (_currentDriverId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen(driverId: _currentDriverId!),
            ),
          );
        }
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.push(
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
        title: const Text("New Trip"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: "Origin (e.g., School)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: "Destination (e.g., Residential Area)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (originController.text.isEmpty || destinationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter origin and destination!")),
                );
                return;
              }
              Navigator.pop(context);

              if (_currentDriverId == null) return;

              final tripId = await tripService.createTrip(
                vehicleId: _currentDriverId!,
                driverId: _currentDriverId!,
                origin: originController.text,
                destination: destinationController.text,
              );

              if (tripId != null) {
                _tripProvider.createNewTrip(
                  tripId,
                  _currentDriverId!,
                  originController.text,
                  destinationController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Trip created (ID: $tripId)!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Create Trip"
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startTrip() async {
    if (_currentDriverId == null) return;

    final tripId = _tripProvider.getCurrentTripId(_currentDriverId!);
    if (tripId == null) return;

    final success = await TripService().startTrip(tripId);
    if (success) {
      _tripProvider.startTrip(_currentDriverId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Viaje iniciado!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al iniciar viaje"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _endTrip() async {
    if (_currentDriverId == null) return;

    final tripId = _tripProvider.getCurrentTripId(_currentDriverId!);
    if (tripId == null) return;

    final success = await TripService().endTrip(tripId);
    if (success) {
      _tripProvider.endTrip(_currentDriverId!);
      _tripProvider.resetTrip(_currentDriverId!);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Viaje finalizado!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al finalizar viaje"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _shouldShowTripControls() {
    return _currentDriverId != null &&
        _tripProvider.hasActiveTrip(_currentDriverId!);
  }

  @override
  Widget build(BuildContext context) {
    final isTripStarted = _currentDriverId != null
        ? _tripProvider.isTripStarted(_currentDriverId!)
        : false;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _currentDriverId != null
          ? FloatingActionButton(
        onPressed: () => _showCreateTripDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Crear Viaje',
        backgroundColor: theme.colorScheme.primary,
      )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo and welcome message
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/CodeMinds-Logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome again,',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Emergency Button
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Handle emergency button press
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/EmergencyButton.png',
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Emergency Button',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Past Trips Card
                    _buildActionCard(
                      context,
                      'assets/images/PastTrips.png',
                      'Past Trips',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PastTripsScreen()),
                        );
                      },
                    ),
                    // Attendance Card
                    _buildActionCard(
                      context,
                      'assets/images/Attendace.png',
                      'Attendance',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttendanceScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Trip Controls
                if (_shouldShowTripControls() && !isTripStarted)
                  ElevatedButton(
                    onPressed: _startTrip,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Start Trip"),
                  ),
                if (_shouldShowTripControls() && isTripStarted)
                  ElevatedButton(
                    onPressed: _endTrip,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("End Trip"),
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

  Widget _buildActionCard(
      BuildContext context, String imagePath, String title, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 60,
                width: 60,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}