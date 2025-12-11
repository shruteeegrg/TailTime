import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class PetOnboardingScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const PetOnboardingScreen({super.key, required this.userId, required this.userName});

  @override
  State<PetOnboardingScreen> createState() => _PetOnboardingScreenState();
}

class _PetOnboardingScreenState extends State<PetOnboardingScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedSpecies = 'Dog';
  bool _isLoading = false;

  void _submitPet() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);

    Map<String, dynamic>? newPet = await ApiService.addPet(
      widget.userId,
      _nameController.text,
      _selectedSpecies,
      _breedController.text,
      _ageController.text,
      _weightController.text,
    );

    if (newPet != null) {
      if (!mounted) return;
      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
              userId: widget.userId,
              userName: widget.userName
          ),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save pet")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tell us about\nyour best friend! 🐾",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFFF4081)),
              ),
              const SizedBox(height: 10),
              const Text("This helps us customize care reminders.", style: TextStyle(color: Colors.grey, fontSize: 16)),

              const SizedBox(height: 30),

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),

              const Text("Species", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _speciesCard("Dog", Icons.pets),
                  _speciesCard("Cat", Icons.cruelty_free),
                  _speciesCard("Bird", Icons.flutter_dash),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextField("Pet Name", _nameController),
              const SizedBox(height: 15),
              _buildTextField("Breed (e.g. Golden Retriever)", _breedController),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField("Age (Years)", _ageController, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("Weight (kg)", _weightController, isNumber: true)),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitPet,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save & Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _speciesCard(String label, IconData icon) {
    bool isSelected = _selectedSpecies == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedSpecies = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4081) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}