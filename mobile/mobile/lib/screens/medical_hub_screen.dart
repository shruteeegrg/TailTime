import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have this package
import '../services/api_service.dart';

class MedicalHubScreen extends StatefulWidget {
  final String userId;
  const MedicalHubScreen({super.key, required this.userId});

  @override
  State<MedicalHubScreen> createState() => _MedicalHubScreenState();
}

class _MedicalHubScreenState extends State<MedicalHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchRecords();
  }

  void _fetchRecords() async {
    var records = await ApiService.getMedicalRecords(widget.userId);
    setState(() {
      _allRecords = records;
      _isLoading = false;
    });
  }

  // Filter records based on the tab (vaccine, medication, etc.)
  List<dynamic> _getRecordsByCategory(String category) {
    return _allRecords.where((rec) => rec['category'] == category).toList();
  }

  void _showAddDialog() {
    // Determine category based on current tab
    List<String> categories = ['vaccine', 'medication', 'vital', 'visit'];
    String currentCategory = categories[_tabController.index];

    final titleController = TextEditingController();
    final valueController = TextEditingController(); // For weight/notes

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add ${currentCategory.toUpperCase()}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: currentCategory == 'vital' ? "Type (e.g. Weight)" : "Name (e.g. Rabies)",
              ),
            ),
            if (currentCategory == 'vital')
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: "Value (e.g. 12kg)"),
              ),
            if (currentCategory != 'vital')
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: "Notes / Doctor Name"),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.addMedicalRecord({
                "userId": widget.userId,
                "category": currentCategory,
                "title": titleController.text,
                "notes": valueController.text,
                "value": valueController.text,
                "dateGiven": DateTime.now().toIso8601String(),
                // Logic for due date could be added here (e.g., +1 year)
              });
              if (!mounted) return;
              Navigator.pop(context);
              _fetchRecords();
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Medical Hub"),
        backgroundColor: const Color(0xFFFF4081),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.shield), text: "Vaccines"),
            Tab(icon: Icon(Icons.medication), text: "Meds"),
            Tab(icon: Icon(Icons.monitor_heart), text: "Vitals"),
            Tab(icon: Icon(Icons.local_hospital), text: "Visits"),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFFF4081),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Record", style: TextStyle(color: Colors.white)),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildList("vaccine"),
          _buildList("medication"),
          _buildList("vital"),
          _buildList("visit"),
        ],
      ),
    );
  }

  Widget _buildList(String category) {
    List<dynamic> records = _getRecordsByCategory(category);

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No $category records yet", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        var rec = records[index];
        // Check if overdue (Simple logic: if no nextDueDate, ignore. If past, ALERT)
        bool isOverdue = false; // Implement logic if you pass nextDueDate

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: category == 'vaccine' ? Colors.blue[50] : Colors.purple[50],
                  shape: BoxShape.circle
              ),
              child: Icon(
                  category == 'vital' ? Icons.monitor_heart : Icons.medical_services,
                  color: const Color(0xFFFF4081)
              ),
            ),
            title: Text(
              rec['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(rec['dateGiven']))}"),
                if (rec['notes'] != null && rec['notes'].isNotEmpty)
                  Text("Note: ${rec['notes']}", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            trailing: category == 'vaccine'
                ? const Chip(label: Text("Active"), backgroundColor: Colors.greenAccent)
                : null,
          ),
        );
      },
    );
  }
}