import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar_driver.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:codeminds_mobile_application/core/app_constants.dart';

class AttendanceScreen extends StatefulWidget {
  final int driverId;
  final String authToken;

  const AttendanceScreen({
    Key? key,
    required this.driverId,
    required this.authToken,
  }) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> students = [];
  bool _isLoading = true;
  bool _hasActiveTrip = false;
  int? _activeTripId;

  @override
  void initState() {
    super.initState();
    _fetchActiveTrip();
  }

  Future<void> _fetchActiveTrip() async {
    setState(() => _isLoading = true);

    try {
      final url = '${AppConstants.baseUrl}/vehicle-tracking/trips/active/driver/${widget.driverId}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
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
        child: Text('No hay estudiantes en este viaje', style: TextStyle(fontSize: 18)),
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
          icon: Icon(student['attended'] == true
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
    );
  }
}