import 'package:flutter/material.dart';
import 'current_complaints_screen.dart';
import 'past_complaints_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Current',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Past',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CurrentComplaintsScreen(),
          PastComplaintsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to file complaint
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File Complaint - Feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('File Complaint'),
      ),
    );
  }
}
