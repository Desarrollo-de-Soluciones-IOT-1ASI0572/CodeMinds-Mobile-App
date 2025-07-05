import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/profiles/presentation/register_photo_screen.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogoEdugo(), // Logo Edugo
              const SizedBox(height: 16.0),

              // Título "Driver Setup"
              const Text(
                'Driver Setup',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16.0),

              _buildTextField(label: 'DNI'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Plate'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Vehicle'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Vehicle Model'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'License Number'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Insurance Number'),
              const SizedBox(height: 16.0),

              _buildNextButton(context),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  // Logo Edugo
  Widget _buildLogoEdugo() {
    return Image.asset(
      'assets/images/CodeMinds-Logo.png',
      height: 100,
      width: 100,
    );
  }

  Widget _buildTextField({required String label, bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFDE7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.cyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPhotoScreen(selectedRole: 'Driver',)),
          );
        },
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}