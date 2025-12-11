import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'activity_screen.dart';
import 'care_calendar_screen.dart';
import 'medical_hub_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String userId;
  const DashboardScreen({super.key, required this.userName, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Card 1: Pet Info
  String petName = "Loading...";
  String breed = "...";
  double weight = 0;
  int todaySteps = 0; // Or minutes, depending on your preference

  // Card 2: Schedules
  List<dynamic> _upcomingEvents = [];

  // Card 3: Chart
  String _selectedChart = 'walk'; // walk, sleep, meal
  List<double> _chartData = [0, 0, 0, 0, 0, 0, 0]; // Changed to double for hours
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  // Central function to refresh all dashboard components
  Future<void> _fetchAllData() async {
    _fetchPetInfo();
    _fetchUpcomingEvents();
    _fetchChartData();
  }

  void _fetchPetInfo() async {
    var pet = await ApiService.getPetData(widget.userId);
    if (pet != null) {
      if (mounted) {
        setState(() {
          petName = pet['petName'];
          breed = pet['breed'] ?? "Unknown";
          weight = (pet['weight'] ?? 0).toDouble();
          // If you updated backend to send 'dailyWalkMinutes', use that here
          todaySteps = (pet['dailySteps'] ?? 0);
          _isLoading = false;
        });
      }
    }
  }

  void _fetchUpcomingEvents() async {
    var events = await ApiService.getEvents(widget.userId);

    // Logic: Filter for future events only and sort by date
    var now = DateTime.now();
    var futureEvents = events.where((e) {
      DateTime eventDate = DateTime.parse(e['date']);
      return eventDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();

    // Sort: Closest date first
    futureEvents.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    if (mounted) {
      setState(() {
        _upcomingEvents = futureEvents.take(3).toList(); // Show top 3
      });
    }
  }

  void _fetchChartData() async {
    var stats = await ApiService.getWeeklyStats(widget.userId, _selectedChart);
    List<double> newData = [0, 0, 0, 0, 0, 0, 0];

    for (var s in stats) {
      // MongoDB returns _id: 1=Sun ... 7=Sat
      int idx = s['_id'] - 1;
      if (idx >= 0 && idx < 7) {
        double val = (s['total'] as num).toDouble();

        // CONVERSION LOGIC
        if (_selectedChart == 'walk') {
          // Backend sends Minutes -> Convert to Hours for display
          newData[idx] = val / 60.0;
        } else {
          // Sleep is already Hours, Meal is Count
          newData[idx] = val;
        }
      }
    }
    if (mounted) setState(() => _chartData = newData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Soft grey background

      // Floating Action Button (Only for logging activity)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityScreen(userId: widget.userId)))
              .then((_) => _fetchAllData()); // Refresh dashboard when coming back
        },
        backgroundColor: const Color(0xFFFF4081),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home, color: Color(0xFFFF4081)), onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.grey),
                  // FIX: Add .then() to refresh data when returning
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CareCalendarScreen(userId: widget.userId))
                  ).then((_) => _fetchAllData())
              ),
              const SizedBox(width: 40), // Gap for FAB
              IconButton(
                  icon: const Icon(Icons.medical_services, color: Colors.grey),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalHubScreen(userId: widget.userId)))
              ),
              IconButton(
                  icon: const Icon(Icons.person, color: Colors.grey),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)))
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------
              // CARD 1: PET INFO
              // ---------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Row(
                  children: [
                    // Pet Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFFFF4081), shape: BoxShape.circle),
                      child: const CircleAvatar(radius: 35, backgroundImage: NetworkImage("https://placedog.net/500")),
                    ),
                    const SizedBox(width: 20),
                    // Info Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(petName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text("$breed  •  ${weight}kg", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          const SizedBox(height: 8),
                          // Daily Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.show_chart, size: 16, color: Colors.blue),
                                const SizedBox(width: 5),
                                Text("Recent Activity Logged", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------------------------------------------
              // CARD 2: UPCOMING SCHEDULES (From Care Calendar)
              // ---------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Upcoming Schedules", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    // FIX: Add .then() here too
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CareCalendarScreen(userId: widget.userId))
                      ).then((_) => _fetchAllData()),
                      child: const Text("See All", style: TextStyle(color: Color(0xFFFF4081)))
                  )
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: _upcomingEvents.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("No upcoming events. Relax! 🐾", style: TextStyle(color: Colors.grey))),
                )
                    : Column(
                  children: _upcomingEvents.map((event) {
                    // Determine color/icon based on type
                    Color dotColor = Colors.grey;
                    IconData icon = Icons.circle;
                    if (event['type'] == 'vet') { dotColor = Colors.red; icon = Icons.local_hospital; }
                    if (event['type'] == 'grooming') { dotColor = Colors.blue; icon = Icons.cut; }
                    if (event['type'] == 'medication') { dotColor = Colors.green; icon = Icons.medication; }

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: dotColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(icon, color: dotColor, size: 20),
                      ),
                      title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(event['date']))),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 25),

              // ---------------------------------------------------
              // CARD 3: WEEKLY TRENDS CHART
              // ---------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                height: 420, // Taller to fit legends
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Weekly Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedChart,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF4081)),
                              items: const [
                                DropdownMenuItem(value: 'walk', child: Text("Walk (Hours)")),
                                DropdownMenuItem(value: 'sleep', child: Text("Sleep (Hours)")),
                                DropdownMenuItem(value: 'meal', child: Text("Meals (Qty)")),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedChart = val!);
                                _fetchChartData();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),

                    // The Bar Chart
                    Expanded(
                      child: BarChart(
                        BarChartData(
                            barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) => Colors.blueGrey,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      rod.toY.toStringAsFixed(1),
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    );
                                  },
                                )
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey))
                                  )
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                                const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                                if (val.toInt() >= 0 && val.toInt() < 7) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(days[val.toInt()], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  );
                                }
                                return const Text("");
                              })),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            barGroups: _chartData.asMap().entries.map((e) {
                              return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                        toY: e.value,
                                        color: _getBarColor(),
                                        width: 16,
                                        borderRadius: BorderRadius.circular(6),
                                        backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: _getMaxY(), // Background height
                                            color: Colors.grey[100]
                                        )
                                    )
                                  ]
                              );
                            }).toList()
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // LEGEND SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 12, height: 12, color: _getBarColor()),
                        const SizedBox(width: 8),
                        Text(
                            _selectedChart == 'walk' ? "Walk Duration (Hours)"
                                : (_selectedChart == 'sleep' ? "Sleep Duration (Hours)" : "Total Meals"),
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold)
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarColor() {
    if (_selectedChart == 'walk') return Colors.blue;
    if (_selectedChart == 'sleep') return Colors.purple;
    return Colors.orange;
  }

  double _getMaxY() {
    if (_selectedChart == 'walk') return 5; // Max visual for walk (5 hours)
    if (_selectedChart == 'sleep') return 12; // 12 hours max visual
    return 5; // 5 meals max visual
  }
}