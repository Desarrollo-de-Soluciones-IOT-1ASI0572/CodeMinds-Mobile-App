import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeminds_mobile_application/screens/login_screen.dart';

import 'providers/TripProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TripProvider()),
        // Puedes añadir más providers aquí si los necesitas
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      // Opcional: configura rutas con nombre si las usas
      routes: {
        // '/login': (context) => const LoginScreen(),
        // '/home': (context) => const HomeScreen(),
      },
    );
  }
}