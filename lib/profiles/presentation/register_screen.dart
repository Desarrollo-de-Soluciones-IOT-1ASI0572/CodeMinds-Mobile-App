import 'dart:convert';

import 'package:codeminds_mobile_application/profiles/presentation/login_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/profile_create.dart';
import 'package:codeminds_mobile_application/profiles/presentation/register_photo_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/profiles/presentation/register_driver_screen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? selectedRole;
  bool agreedTerms = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              _buildLogoEdugo(),
              const SizedBox(height: 32.0),

              // Título "Register"
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 32.0),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
              ),
              const SizedBox(height: 24.0),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24.0),

              _buildDropdown(
                label: 'Select a role',
                items: ['Parent', 'Driver'],
                value: selectedRole,
                onChanged: (val) => setState(() => selectedRole = val),
              ),
              const SizedBox(height: 24.0),

              _buildTermsCheckbox(agreedTerms, (val) {
                setState(() => agreedTerms = val ?? false);
              }),
              const SizedBox(height: 32.0),

              _buildRegisterButton(context, agreedTerms),
              const SizedBox(height: 24.0),

              _buildLoginText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoEdugo() {
    return Image.asset(
      'assets/images/CodeMinds-Logo.png',
      height: 120,
      width: 120,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFDE7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTermsCheckbox(bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1E3A8A),
        ),
        const Expanded(
          child: Text(
            'I agree to the Terms and Conditions',
            style: TextStyle(color: Colors.black87, fontSize: 14),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: enabled && _isFormValid()
            ? () {
                _handleRegister(context);
              }
            : null,
        child: const Text(
          'Register',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                Navigator.pop(context);
              },
          ),
        ],
      ),
    );
  }

  bool _isFormValid() {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        selectedRole != null;
  }

  void _handleRegister(BuildContext context) async {
    // Convertir role a formato requerido para el POST
    String roleForPost = _getRoleForPost(selectedRole!);

    // Datos para el POST
    Map<String, dynamic> registerData = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'roles': [roleForPost],
    };

    print('Datos para POST: $registerData');

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Hacer POST request
      final response = await http.post(
        Uri.parse(
            'https://edugo-service-de983aa97099.herokuapp.com/api/v1/authentication/sign-up'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registerData),
      );

      // Cerrar loading
      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registro exitoso
        final responseData = jsonDecode(response.body);
        print('Registro exitoso: $responseData');

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegación condicional
        if (selectedRole == "Driver") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileCreateScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileCreateScreen()),
          );
        }
      } else {
        // Error en el registro
        final errorData = jsonDecode(response.body);
        print('Error en registro: ${response.statusCode} - $errorData');

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error en el registro: ${errorData['message'] ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si aún está abierto
      Navigator.pop(context);

      print('Excepción durante el registro: $e');

      // Mostrar mensaje de error de conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRoleForPost(String selectedRole) {
    switch (selectedRole) {
      case 'Parent':
        return 'ROLE_PARENT';
      case 'Driver':
        return 'ROLE_DRIVER';
      default:
        return 'ROLE_PARENT';
    }
  }
}
