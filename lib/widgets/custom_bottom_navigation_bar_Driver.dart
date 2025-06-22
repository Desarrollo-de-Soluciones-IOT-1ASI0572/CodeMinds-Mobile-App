import 'package:flutter/material.dart';

class CustomBottomNavigationBarDriver extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBarDriver({
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Notifications'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Account'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      onTap: onTap,
    );
  }
}
