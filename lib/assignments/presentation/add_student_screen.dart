import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/profiles/application/services/profile_service.dart';
import 'package:codeminds_mobile_application/profiles/domain/entities/profile.dart';
import 'package:codeminds_mobile_application/assignments/domain/entities/student.dart';
import 'package:codeminds_mobile_application/assignments/application/services/student_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _schoolAddressController = TextEditingController();
  String? _imagePath;
  int? _selectedDriverId;
  List<ProfileModel> _drivers = [];
  final StudentService _studentService = StudentService();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      List<ProfileModel> drivers = await _profileService.fetchProfilesByRole('ROLE_DRIVER');
      setState(() {
        _drivers = drivers;
      });
    } catch (e) {
      print('Error al obtener los conductores: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token'); // Asegúrate de que el token esté guardado como 'jwt_token'
  }

  // Método para crear el estudiante
  Future<void> _createStudent() async {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final homeAddress = _addressController.text.trim();
    final schoolAddress = _schoolAddressController.text.trim();

    if (name.isEmpty || lastName.isEmpty || homeAddress.isEmpty || schoolAddress.isEmpty) {
      _showError('Por favor, completa todos los campos');
      return;
    }

    if (_selectedDriverId == null) {
      _showError('Por favor, selecciona un conductor');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? parentProfileId = prefs.getInt('user_id');

      if (parentProfileId == null) {
        _showError('No se encontró el perfil del padre');
        return;
      }

      final student = Student(
        id: 0,
        name: name,
        lastName: lastName,
        homeAddress: homeAddress,
        schoolAddress: schoolAddress,
        studentPhotoUrl: _imagePath ?? 'default_student.png',
        parentProfileId: parentProfileId,
        driverId: _selectedDriverId!,
      );

      await _studentService.postStudent(student, parentProfileId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error al crear el estudiante: $e');
    }
  }




  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Student'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('First Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Last Name', _lastNameController),
              const SizedBox(height: 16),
              _buildTextField('Home Address', _addressController),
              const SizedBox(height: 16),
              _buildTextField('School Address', _schoolAddressController),
              const SizedBox(height: 16),

              // Dropdown para seleccionar conductor
              const Text('Select Driver', style: TextStyle(fontSize: 16)),
              _drivers.isNotEmpty
                  ? DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Select Driver'),
                value: _selectedDriverId,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedDriverId = newValue;
                  });
                },
                items: _drivers.map<DropdownMenuItem<int>>((ProfileModel driver) {
                  return DropdownMenuItem<int>(
                    value: driver.id,
                    child: Text(driver.fullName),
                  );
                }).toList(),
              )
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),

              // Botón para seleccionar una foto
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  ),
                  onPressed: () {
                    setState(() {
                      _imagePath = 'https://content.elmueble.com/medio/2024/03/24/nombres-de-nina-con-significado-poderoso_19b192f7_240324191926_900x900.jpg';
                    });
                  },
                  child: const Text('Select Photo', style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // Botones "Save" y "Cancel"
              _buildButton('Save', Colors.blue, _createStudent),
              const SizedBox(height: 12),
              _buildButton('Cancel', Colors.grey, () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
