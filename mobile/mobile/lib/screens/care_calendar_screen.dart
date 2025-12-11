import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CareCalendarScreen extends StatefulWidget {
  final String userId;
  const CareCalendarScreen({super.key, required this.userId});

  @override
  State<CareCalendarScreen> createState() => _CareCalendarScreenState();
}

class _CareCalendarScreenState extends State<CareCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Stores events: { DateTime: [Event1, Event2] }
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  void _fetchEvents() async {
    var eventsList = await ApiService.getEvents(widget.userId);
    Map<DateTime, List<dynamic>> data = {};

    for (var event in eventsList) {
      DateTime date = DateTime.parse(event['date']);
      // Normalize date to remove time (so it matches the calendar day)
      DateTime dateKey = DateTime.utc(date.year, date.month, date.day);

      if (data[dateKey] == null) data[dateKey] = [];
      data[dateKey]!.add(event);
    }

    if (mounted) {
      setState(() {
        _events = data;
        // Refresh selected events list if we are currently looking at a day
        if (_selectedDay != null) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    DateTime dateKey = DateTime.utc(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  // LOGIC: Delete Event
  void _deleteEvent(String eventId) async {
    bool success = await ApiService.deleteEvent(eventId);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Deleted")));
      _fetchEvents(); // Refresh the list and dots
    }
  }

  // Dialog to Add New Event
  void _showAddEventDialog() {
    final titleController = TextEditingController();
    String selectedType = 'vet'; // Default

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add Reminder"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Event Title"),
                  ),
                  const SizedBox(height: 15),
                  DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'vet', child: Text("🔴 Vet Visit")),
                      DropdownMenuItem(value: 'grooming', child: Text("🔵 Grooming")),
                      DropdownMenuItem(value: 'medication', child: Text("🟢 Medication")),
                      DropdownMenuItem(value: 'other', child: Text("⚪ Other")),
                    ],
                    onChanged: (val) {
                      setStateDialog(() => selectedType = val!);
                    },
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      await ApiService.addEvent(
                          widget.userId,
                          titleController.text,
                          _selectedDay ?? DateTime.now(),
                          selectedType
                      );
                      if (context.mounted) Navigator.pop(context);
                      _fetchEvents(); // Refresh calendar
                    }
                  },
                  child: const Text("Save"),
                )
              ],
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Care Calendar")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color(0xFFFF4081),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay, // This puts the dots on the calendar
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Color(0xFFFF80AB), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Color(0xFFFF4081), shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents = _getEventsForDay(selectedDay);
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(child: Text("No events for this day", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                var event = _selectedEvents[index];
                Color dotColor = Colors.grey;
                if (event['type'] == 'vet') dotColor = Colors.red;
                if (event['type'] == 'grooming') dotColor = Colors.blue;
                if (event['type'] == 'medication') dotColor = Colors.green;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.circle, color: dotColor, size: 15),
                    title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('hh:mm a').format(DateTime.parse(event['date']))),
                    // DELETE BUTTON ADDED HERE
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteEvent(event['_id']),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}