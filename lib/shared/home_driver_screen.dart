import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const HomeDriverScreen({
    super.key,
    required this.name,
    required this.selectedIndex
  });

  @override
  State<HomeDriverScreen> createState() => _HomeDriverScreenState();
}

class _HomeDriverScreenState extends State<HomeDriverScreen> {
  int _selectedIndex = 0;
  late TripProvider _tripProvider;
  int? _currentDriverId;
  bool _isEmergencyActive = false;

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
    setState(() => _selectedIndex = index);

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
            builder: (context) => const NotificationScreen(selectedIndex: 2),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountScreen(selectedIndex: 3),
          ),
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
              if (originController.text.isEmpty ||
                  destinationController.text.isEmpty) {
                _showSnackbar("Enter origin and destination!", Colors.red);
                return;
              }
              Navigator.pop(context);

              if (_currentDriverId == null) {
                _showSnackbar("Driver ID not found", Colors.red);
                return;
              }

              try {
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
                  _showSnackbar("Trip created (ID: $tripId)!", Colors.green);
                }
              } catch (e) {
                _showSnackbar("Error creating trip: $e", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Create Trip"),
          ),
        ],
      ),
    );
  }

  Future<void> _startTrip() async {
    if (_currentDriverId == null) {
      _showSnackbar("Driver ID not found", Colors.red);
      return;
    }

    final tripId = _tripProvider.getCurrentTripId(_currentDriverId!);
    if (tripId == null) {
      _showSnackbar("No active trip found", Colors.red);
      return;
    }

    try {
      final success = await TripService().startTrip(tripId);
      if (success) {
        _tripProvider.startTrip(_currentDriverId!);
        _showSnackbar("Trip started!", Colors.green);
      } else {
        _showSnackbar("Failed to start trip", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error starting trip: $e", Colors.red);
    }
  }

  Future<void> _endTrip() async {
    if (_currentDriverId == null) {
      _showSnackbar("Driver ID not found", Colors.red);
      return;
    }

    final tripId = _tripProvider.getCurrentTripId(_currentDriverId!);
    if (tripId == null) {
      _showSnackbar("No active trip found", Colors.red);
      return;
    }

    try {
      final success = await TripService().endTrip(tripId);
      if (success) {
        _tripProvider.endTrip(_currentDriverId!);
        _tripProvider.resetTrip(_currentDriverId!);
        setState(() {});
        _showSnackbar("Trip ended!", Colors.green);
      } else {
        _showSnackbar("Failed to end trip", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error ending trip: $e", Colors.red);
    }
  }

  Future<void> _handleEmergency() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Activate Emergency?"),
        content: const Text("This will notify authorities and parents immediately and end the trip. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "ACTIVATE",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ) ?? false;

    if (!confirmed) return;

    if (_currentDriverId == null) {
      _showSnackbar("Driver ID not found", Colors.red);
      return;
    }

    final tripId = _tripProvider.getCurrentTripId(_currentDriverId!);
    if (tripId == null) {
      _showSnackbar("No active trip found", Colors.red);
      return;
    }

    try {
      setState(() => _isEmergencyActive = true);
      HapticFeedback.heavyImpact(); // Vibrate device

      final success = await TripService().activateEmergency(tripId);

      if (success) {
        // 🔑 Finaliza el trip también en frontend
        _tripProvider.endTrip(_currentDriverId!);
        _tripProvider.resetTrip(_currentDriverId!);

        _showEmergencySnackbar();
      } else {
        _showSnackbar("Failed to activate emergency", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isEmergencyActive = false);
    }
  }


  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showEmergencySnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text("EMERGENCY ACTIVATED!")),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  bool _shouldShowTripControls() {
    return _currentDriverId != null &&
        _tripProvider.hasActiveTrip(_currentDriverId!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTripStarted = _currentDriverId != null
        ? _tripProvider.isTripStarted(_currentDriverId!)
        : false;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: (_currentDriverId != null && !_tripProvider.hasActiveTrip(_currentDriverId!))
          ? FloatingActionButton(
        onPressed: () => _showCreateTripDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Trip',
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
                        'Welcome back,',
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

                // Emergency Button (only shown during active trip)
                if (_shouldShowTripControls() && isTripStarted)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isEmergencyActive
                          ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                          : null,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isEmergencyActive ? null : _handleEmergency,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isEmergencyActive
                                  ? [Colors.red.shade900, Colors.red.shade700]
                                  : [Colors.red.shade600, Colors.red.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'EMERGENCY BUTTON',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEmergencyActive
                                    ? 'Emergency assistance requested!'
                                    : 'Press in case of emergency',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              if (_isEmergencyActive)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
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
                            builder: (_) => PastTripsScreen(),
                          ),
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
      BuildContext context,
      String imagePath,
      String title,
      VoidCallback onTap,
      ) {
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