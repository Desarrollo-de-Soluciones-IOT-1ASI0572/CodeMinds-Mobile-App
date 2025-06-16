import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/screens/register_photo_screen.dart';
import 'package:codeminds_mobile_application/screens/register_driver_screen.dart';
// import 'package:codeminds_mobile_application/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedGender;
  String? selectedRole;
  bool agreedTerms = false;

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

              // Título "Register"
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // Color acorde a la imagen
                ),
              ),
              const SizedBox(height: 16.0),

              _buildTextField(label: 'Username'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Email Address'),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Mobile Number'),
              const SizedBox(height: 16.0),

              _buildDropdown(
                label: 'Gender',
                items: ['Male', 'Female', 'Other'],
                value: selectedGender,
                onChanged: (val) => setState(() => selectedGender = val),
              ),
              const SizedBox(height: 16.0),

              _buildDropdown(
                label: 'Select a role',
                items: ['Student', 'Parent', 'Driver'],
                value: selectedRole,
                onChanged: (val) => setState(() => selectedRole = val),
              ),
              const SizedBox(height: 16.0),

              _buildTextField(label: 'Password', obscureText: true),
              const SizedBox(height: 16.0),
              _buildTextField(label: 'Confirm Password', obscureText: true),
              const SizedBox(height: 16.0),

              _buildTermsCheckbox(agreedTerms, (val) {
                setState(() => agreedTerms = val ?? false);
              }),
              const SizedBox(height: 16.0),

              _buildRegisterButton(context, agreedTerms),
              const SizedBox(height: 16.0),

              _buildLoginText(context),
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

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFDE7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTermsCheckbox(bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        const Expanded(
          child: Text(
            'I agree to the Terms and Conditions',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, bool enabled) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.cyan,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: enabled
            ? () {
          if (selectedRole == "Driver") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterDriverScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPhotoScreen(selectedRole: selectedRole ?? "")),
            );
          }
        }
            : null,
        child: const Text(
          'Register',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLoginText(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: "Already have an account? ",
        style: const TextStyle(fontSize: 14.0, color: Colors.black54),
        children: [
          TextSpan(
            text: 'Log In',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const LoginScreen()),
                // );
              },
          ),
        ],
      ),
    );
  }
}