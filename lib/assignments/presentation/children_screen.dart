import 'package:flutter/material.dart';
import 'package:codeminds_mobile_application/shared/home_parent_screen.dart';
import 'package:codeminds_mobile_application/notifications/presentation/notification_screen.dart';
import 'package:codeminds_mobile_application/profiles/presentation/account_screen.dart';
import 'package:codeminds_mobile_application/assignments/presentation/add_student_screen.dart';
import 'package:codeminds_mobile_application/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/student.dart';
import '../application/services/student_service.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  _ChildrenScreenState createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  List<Student> _students = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _selectedIndex = 0;
  final int _itemsPerPage = 5;
  int _currentOffset = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreStudents();
    }
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _students.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId == null) throw Exception('User not logged in');

      final students = await StudentService()
          .getStudentsByParentUserIdPaged(userId, _currentOffset, _itemsPerPage);

      setState(() {
        _students = students;
        _isLoading = false;
        _hasMore = students.length == _itemsPerPage;
        _currentOffset += students.length;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      _showErrorSnackbar('Failed to load students');
    }
  }

  Future<void> _loadMoreStudents() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId == null) throw Exception('User not logged in');

      final students = await StudentService()
          .getStudentsByParentUserIdPaged(userId, _currentOffset, _itemsPerPage);

      setState(() {
        _students.addAll(students);
        _isLoadingMore = false;
        _hasMore = students.length == _itemsPerPage;
        _currentOffset += students.length;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      _showErrorSnackbar('Failed to load more students');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _onAddStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );

    if (result == true) await _loadStudents();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeParentScreen(
                onSeeMoreNotifications: () {},
                selectedIndex: 0
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const NotificationScreen(selectedIndex: 2)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const AccountScreen(selectedIndex: 3)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Children'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Add Student Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _onAddStudent,
                ),
              ),
              const SizedBox(height: 20),

              // Student List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _students.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 60,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadStudents,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadStudents,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _students.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _students.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : TextButton(
                              onPressed: _loadMoreStudents,
                              child: const Text('Load More'),
                            ),
                          ),
                        );
                      }
                      return _buildStudentCard(_students[index]);
                    },
                  ),
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

  Widget _buildStudentCard(Student student) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showStudentDetails(student),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Student Avatar
              Hero(
                tag: 'student-avatar-${student.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: student.studentPhotoUrl.isNotEmpty
                      ? NetworkImage(student.studentPhotoUrl)
                      : const AssetImage('assets/images/default-avatar.png')
                  as ImageProvider,
                ),
              ),
              const SizedBox(width: 16.0),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.name} ${student.lastName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.schoolAddress,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    // Handle edit
                  } else if (value == 'delete') {
                    _confirmDelete(student);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(Student student) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'student-avatar-${student.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: student.studentPhotoUrl.isNotEmpty
                        ? NetworkImage(student.studentPhotoUrl)
                        : const AssetImage('assets/images/default-avatar.png')
                    as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${student.name} ${student.lastName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.home, 'Address', student.homeAddress),
              _buildDetailRow(Icons.school, 'School', student.schoolAddress),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Student student) {
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
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Call delete API here
                  setState(() {
                    _students.removeWhere((s) => s.id == student.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student deleted successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete student: $e'),
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}