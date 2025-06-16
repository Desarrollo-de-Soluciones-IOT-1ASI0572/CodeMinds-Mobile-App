import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar_driver.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Map<String, dynamic>> students = [
    {'name': 'Juan Pérez', 'image': 'assets/images/circle-user.png', 'status': ''},
    {'name': 'Carlos Pérez', 'image': 'assets/images/circle-user.png', 'status': ''},
    {'name': 'Jimena Pérez', 'image': 'assets/images/circle-user.png', 'status': ''},
    {'name': 'Camila Pérez', 'image': 'assets/images/circle-user.png', 'status': ''},
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrackingScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
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
              // Logo y título "Attendance"
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
                    'Attendance',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de estudiantes
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildStudentTile(student, index);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Botón "Load More"
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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

  Widget _buildStudentTile(Map<String, dynamic> student, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                // Imagen del estudiante
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(student['image']),
                ),
                const SizedBox(width: 12.0),

                // Nombre del estudiante
                Expanded(
                  child: Text(
                    student['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // Estado de asistencia resaltado
                Text(
                  student['status'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: student['status'] == 'Present' ? Colors.green : student['status'] == 'Absent' ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Botón "Manage Attendance"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showAttendanceModal(index),
                child: const Text(
                  'Manage Attendance',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceModal(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark the Attendance'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                onPressed: () {
                  setState(() {
                    students[index]['status'] = 'Present';
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 50),
                onPressed: () {
                  setState(() {
                    students[index]['status'] = 'Absent';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}