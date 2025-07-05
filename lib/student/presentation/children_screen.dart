import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/shared/notification_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/add_student_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/remote/student.dart';
import '../data/remote/student_service.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  _ChildrenScreenState createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  List<StudentModel> _students = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');
    if (userId == null) {
      setState(() {
        _students = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final students = await StudentService().getStudentsByParentUserId(userId);
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _students = [];
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeParentScreen(
                    onSeeMoreNotifications: () {}, selectedIndex: 0)));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const NotificationScreen(selectedIndex: 2)));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AccountScreen(selectedIndex: 3)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/CodeMinds-Logo.png',
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Children',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddStudentScreen()),
                    );
                  },
                  child: const Text(
                    'Add Student',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _students.isEmpty
                        ? const Center(child: Text('No students found.'))
                        : ListView.builder(
                            itemCount: _students.length,
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              return _buildChildTile(student, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildChildTile(StudentModel student, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: student.studentPhotoUrl.isNotEmpty
                  ? NetworkImage(student.studentPhotoUrl)
                  : const AssetImage('assets/images/circle-user.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                '${student.name} ${student.lastName}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.blue),
              onPressed: () => _showStudentDetails(student),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(student, index),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${student.name} ${student.lastName}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Full Name:'),
              Text('${student.name} ${student.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Address:'),
              Text(student.homeAddress,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('School:'),
              Text(student.schoolAddress,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(StudentModel student, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _students.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
