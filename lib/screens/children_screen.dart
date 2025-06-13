import 'package:flutter/material.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  _ChildrenScreenState createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  final List<Map<String, String>> childrenData = [
    {'name': 'Juan Pérez', 'image': 'assets/images/circle-user.png'},
    {'name': 'María López', 'image': 'assets/images/circle-user.png'},
    {'name': 'Carlos Gómez', 'image': 'assets/images/circle-user.png'},
    {'name': 'Ana Torres', 'image': 'assets/images/circle-user.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/CodeMinds-Logo.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              "Children",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: childrenData.length,
              itemBuilder: (context, index) {
                return _buildChildTile(
                  childrenData[index]['name']!,
                  childrenData[index]['image']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildTile(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
