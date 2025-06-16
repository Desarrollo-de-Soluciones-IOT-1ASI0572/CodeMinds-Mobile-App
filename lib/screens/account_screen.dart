import 'package:flutter/material.dart';

import 'account_Update_screen.dart';
// import 'package:codeminds_mobile_application/screens/login_screen.dart';


class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 120),

            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/circle-user.png'),
            ),
            const SizedBox(height: 16.0),

            const Text(
              'Name: Juan Pérez',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Email: juan.perez@email.com',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Phone Number: +51 987 654 321',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 16.0),

            _buildButton('Update Information', Icons.edit, Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountUpdateScreen()),
              );
            }),
            const SizedBox(height: 12.0),
            _buildButton('Delete Account', Icons.delete, Colors.red, () {}),
            const SizedBox(height: 12.0),
            _buildButton('Log Out', Icons.logout, Colors.black, () {
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (_) => const LoginScreen()),
              //       (route) => false,
              // );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}