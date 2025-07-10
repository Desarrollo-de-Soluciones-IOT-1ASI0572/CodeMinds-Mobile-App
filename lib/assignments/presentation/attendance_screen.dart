import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../profiles/presentation/account_screen.dart';
import '../../shared/widgets/custom_bottom_navigation_bar_Driver.dart';
import '../../tracking/application/services/trip_service.dart';
import '../../tracking/presentation/tracking_screen.dart';
import '../../shared/home_driver_screen.dart';
import '../../notifications/presentation/notification_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, dynamic>> students = [];
  bool _isLoading = true;
  bool _hasActiveTrip = false;
  int? _activeTripId;
  int _selectedIndex = 0;
  final TripService _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _fetchActiveTrip();
  }

  Future<void> _fetchActiveTrip() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    try {
      final activeTrips = await _tripService.getActiveTripByDriver(userId!);
      if (activeTrips.isNotEmpty) {
        final trip = activeTrips.first;

        setState(() {
          _hasActiveTrip = true;
          _activeTripId = trip.id;
        });

        // Always use getTripStudents for real-time status.
        await _loadStudents();
      } else {
        setState(() => _hasActiveTrip = false);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_activeTripId == null) return;
    setState(() => _isLoading = true);
    try {
      final studentsList = await _tripService.getTripStudents(_activeTripId!);
      setState(() => students = studentsList);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasActiveTrip) {
      return const Center(
        child: Text(
          'No active trips',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    if (students.isEmpty) {
      return const Center(
        child: Text(
          'No students in this trip',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) =>
          _buildStudentTile(students[index]),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> studentData) {
    final student = studentData['student'];
    final status = _determineStatus(studentData);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
          _getStudentImage(student['studentPhotoUrl']),
        ),
        title: Text('${student['name']} ${student['lastName']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${student['homeAddress']}'),
            Text('Status: ${status['text']}',
                style: TextStyle(color: status['color'])),
            if (status['time'] != null) Text('🕒 ${status['time']}'),
          ],
        ),
        trailing: Icon(
          status['icon'],
          color: status['color'],
        ),
      ),
    );
  }

  Map<String, dynamic> _determineStatus(Map<String, dynamic> student) {
    if (student['exitedAt'] != null) {
      return {
        'text': 'Completed',
        'color': Colors.blue,
        'time': _formatTime(student['exitedAt']),
        'icon': Icons.check_circle
      };
    } else if (student['boardedAt'] != null) {
      return {
        'text': 'On board',
        'color': Colors.green,
        'time': _formatTime(student['boardedAt']),
        'icon': Icons.directions_bus
      };
    } else {
      return {
        'text': 'Pending',
        'color': Colors.orange,
        'time': null,
        'icon': Icons.pending
      };
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    return timestamp.substring(11, 16);
  }

  ImageProvider _getStudentImage(String photoUrl) {
    return photoUrl.startsWith('http')
        ? NetworkImage(photoUrl)
        : const AssetImage('assets/default_avatar.png');
  }

  void _navigateToHomeDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? "Default Name";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeDriverScreen(
          name: userName,
          selectedIndex: 0,
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        _navigateToHomeDriver();
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const TrackingScreen(selectedIndex: 1)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Control'),
        actions: [
          if (_hasActiveTrip)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchActiveTrip,
            ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: CustomBottomNavigationBarDriver(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
