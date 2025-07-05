import 'package:flutter/material.dart';

class AccountUpdateScreen extends StatefulWidget {
  const AccountUpdateScreen({super.key});

  @override
  _AccountUpdateScreenState createState() => _AccountUpdateScreenState();
}

class _AccountUpdateScreenState extends State<AccountUpdateScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Juan Pérez');
  final TextEditingController _emailController = TextEditingController(text: 'juan.perez@email.com');
  final TextEditingController _phoneController = TextEditingController(text: '+51 987 654 321');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/circle-user.png'),
            ),
            const SizedBox(height: 16.0),

            _buildTextField('Name', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', _phoneController),
            const SizedBox(height: 24),

            _buildButton('Save Changes', Colors.blue, () {
              // Guardar cambios y regresar
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _buildButton('Cancel', Colors.grey, () {
              Navigator.pop(context);
            }),
          ],
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
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
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