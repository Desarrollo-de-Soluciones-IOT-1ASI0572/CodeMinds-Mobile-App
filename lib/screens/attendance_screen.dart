import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/shared/app_constants.dart';
import 'package:codeminds_mobile_application/shared/home_driver_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar_Driver.dart';
import 'package:codeminds_mobile_application/tracking/presentation/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> students = [];
  bool _isLoading = true;
  bool _hasActiveTrip = false;
  int? _activeTripId;

  int _selectedIndex = 0;

  void _navigateToHomeDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Default Name";
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
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToHomeDriver();
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TrackingScreen(selectedIndex: 1)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchActiveTrip();
  }

  Future<void> _fetchActiveTrip() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    final String? token = prefs.getString('jwt_token');

    try {
      final url =
          '${AppConstants.baseUrl}/vehicle-tracking/trips/active/driver/${userId!}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token!}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _hasActiveTrip = true;
            _activeTripId = data[0]['id'];
            students = data[0]['students'] ?? [];
          });
        } else {
          setState(() => _hasActiveTrip = false);
        }
      } else {
        throw Exception('Failed to load active trip');
      }
    } catch (e) {
      print('Error: $e');
      // Manejar error
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
        child: Text('No tienes viajes activos', style: TextStyle(fontSize: 18)),
      );
    }

    if (students.isEmpty) {
      return const Center(
        child: Text('No hay estudiantes en este viaje',
            style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentTile(student, index);
      },
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student, int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(student['studentPhotoUrl']),
        ),
        title: Text('${student['name']} ${student['lastName']}'),
        subtitle: Text(student['homeAddress']),
        trailing: IconButton(
          icon: Icon(
              student['attended'] == true
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: student['attended'] == true ? Colors.green : Colors.grey),
          onPressed: () => _toggleAttendance(index),
        ),
      ),
    );
  }

  void _toggleAttendance(int index) {
    setState(() {
      students[index]['attended'] = !(students[index]['attended'] == true);
      // Aquí deberías llamar al endpoint para actualizar en backend
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Asistencia'),
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
