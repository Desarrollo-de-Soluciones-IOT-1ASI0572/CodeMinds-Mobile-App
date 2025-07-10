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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _schoolAddressController = TextEditingController();
  String? _imagePath;
  int? _selectedDriverId;
  List<ProfileModel> _drivers = [];
  bool _isLoading = false;
  final StudentService _studentService = StudentService();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _schoolAddressController.dispose();
    super.dispose();
  }

  Future<void> _fetchDrivers() async {
    try {
      setState(() => _isLoading = true);
      final drivers = await _profileService.fetchProfilesByRole('ROLE_DRIVER');
      setState(() => _drivers = drivers);
    } catch (e) {
      _showError('Error loading drivers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDriverId == null) {
      _showError('Please select a driver');
      return;
    }

    try {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final parentProfileId = prefs.getInt('user_id');

      if (parentProfileId == null) {
        _showError('Parent profile not found');
        return;
      }

      final student = Student(
        id: 0,
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        homeAddress: _addressController.text.trim(),
        schoolAddress: _schoolAddressController.text.trim(),
        studentPhotoUrl: _imagePath ?? 'default_student.png',
        parentProfileId: parentProfileId,
        driverId: _selectedDriverId!,
      );

      await _studentService.postStudent(student, parentProfileId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error creating student: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _selectPhoto() async {
    // Simulate photo selection
    setState(() {
      _imagePath = 'https://content.elmueble.com/medio/2024/03/24/nombres-de-nina-con-significado-poderoso_19b192f7_240324191926_900x900.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Student'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _drivers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Photo
              Center(
                child: GestureDetector(
                  onTap: _selectPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: _imagePath != null
                            ? NetworkImage(_imagePath!)
                            : const AssetImage('assets/images/default-student.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              _buildFormField(
                'First Name',
                _nameController,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'Last Name',
                _lastNameController,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'Home Address',
                _addressController,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                'School Address',
                _schoolAddressController,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Driver Selection
              Text(
                'Select Driver',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    hint: const Text('Choose driver'),
                    value: _selectedDriverId,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedDriverId = newValue;
                      });
                    },
                    items: _drivers.map((ProfileModel driver) {
                      return DropdownMenuItem<int>(
                        value: driver.id,
                        child: Text(driver.fullName),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white, // Añade esto para el color del texto
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white, // Asegúrate de que el indicador sea visible
                        ),
                      )
                          : const Text(
                        'Save Student',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }
}