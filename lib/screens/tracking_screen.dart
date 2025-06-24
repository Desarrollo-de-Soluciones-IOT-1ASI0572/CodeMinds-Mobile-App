import 'package:codeminds_mobile_application/features/student/data/remote/student.dart';
import 'package:codeminds_mobile_application/features/student/data/remote/student_service.dart';
import 'package:codeminds_mobile_application/screens/home_driver_screen.dart';
import 'package:codeminds_mobile_application/screens/home_parent_screen.dart';
import 'package:codeminds_mobile_application/screens/notification_screen.dart';
import 'package:codeminds_mobile_application/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:codeminds_mobile_application/screens/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingScreen extends StatefulWidget {
  final int selectedIndex;
  const TrackingScreen({super.key, required this.selectedIndex});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
 StudentModel? selectedStudent;
  List<StudentModel> students = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Instancia del servicio
  final StudentService _studentService = StudentService();

  Future<void> _loadStudents() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final int? parentUserId = prefs.getInt('user_id');
      
      if (parentUserId == null) {
        throw Exception('ID de usuario padre no encontrado');
      }

      final loadedStudents = await _studentService.getStudentsByParentUserId(parentUserId);

      print('Estudiantes cargados: ${loadedStudents.length}');
      
      setState(() {
        students = loadedStudents;
        if (students.isNotEmpty) {
          selectedStudent = students.first;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar estudiantes: $e';
        isLoading = false;
      });
    }
  }

  int _selectedIndex = 0;

  void _navigateToHomeParent() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Default Name";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeParentScreen(
          name: userName,
          onSeeMoreNotifications: () {},
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
        _navigateToHomeParent();
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
    _loadStudents();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/CodeMinds-Logo.png',
                  height: 50,
                  width: 50,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tracking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Mapa
          SizedBox(
            height: 280,
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(51.5, -0.09),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
              ],
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildInfoRow(
                  'Select Kid:',
                  DropdownButton<StudentModel>(
                    value: selectedStudent,
                    isExpanded: true,
                    onChanged: (StudentModel? newValue) {
                      setState(() {
                        selectedStudent = newValue!;
                      });
                    },
                    items: students.map<DropdownMenuItem<StudentModel>>((StudentModel student) {
              return DropdownMenuItem<StudentModel>(
                value: student,
                child: Text('${student.name} ${student.lastName}'),
              );
            }).toList(),
                  ),
                ),
                if (selectedStudent != null) ...[
                    // Datos de tracking simulados (puedes reemplazar con datos reales más adelante)
                    buildInfoRow('Estado:', const Text('En camino')),
                    buildInfoRow('Distancia(Km):', const Text('2.4 km')),
                    buildInfoRow('Velocidad(km/h):', const Text('15 km/h')),
                  ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget buildInfoRow(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(5),
              ),
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }
}
