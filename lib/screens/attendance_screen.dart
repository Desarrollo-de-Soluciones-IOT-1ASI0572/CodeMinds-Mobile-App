import 'package:flutter/material.dart';
// import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/tracking_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> students = [
      {'name': 'Juan Pérez', 'image': 'assets/images/circle-user.png'},
      {'name': 'Carlos Pérez', 'image': 'assets/images/circle-user.png'},
      {'name': 'Jimena Pérez', 'image': 'assets/images/circle-user.png'},
      {'name': 'Camila Pérez', 'image': 'assets/images/circle-user.png'},
    ];

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
                    'assets/images/CodeMinds-Logo.png', // Ruta del logo
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
                    return _buildStudentTile(student['name'], student['image']);
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
                  onPressed: () {
                    // Acción para cargar más estudiantes
                  },
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

      // Footer de navegación (manteniendo el código anterior)
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeDriverScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrackingScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationParentScreen()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
              break;
          }
        },
      ),
    );
  }

  Widget _buildStudentTile(String name, String imagePath) {
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
                  backgroundImage: AssetImage(imagePath),
                ),
                const SizedBox(width: 12.0),

                // Nombre del estudiante
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                // Botones de acción (✔ para presente, ❌ para ausente)
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    // Marcar presente
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    // Marcar ausente
                  },
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
                onPressed: () {
                  // Acción para gestionar asistencia
                },
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
}