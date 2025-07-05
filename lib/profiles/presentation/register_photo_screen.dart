import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/shared/home_driver_screen.dart';

class RegisterPhotoScreen extends StatelessWidget {
  final String selectedRole;

  const RegisterPhotoScreen({super.key, required this.selectedRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Edugo
              _buildLogo(),
              const SizedBox(height: 16.0),

              // Título "Register"
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16.0),

              _buildUserImage(),
              const SizedBox(height: 16.0),

              const Text(
                'Upload Photo from your phone',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Upload',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA0A0A0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                    ),
                    onPressed: () {
                      bool isDriver = selectedRole == "Driver";

                      /*Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isDriver ? HomeDriverScreen(name: '', driverId: 0) : HomeParentScreen(onSeeMoreNotifications: () {  },),
                        ),
                      );*/
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  // Logo Edugo
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/CodeMinds-Logo.png',
      height: 150,
      width: 150,
    );
  }

  // Imagen de usuario
  Widget _buildUserImage() {
    return Image.asset(
      'assets/images/circle-user.png',
      height: 120,
      width: 120,
    );
  }
}
