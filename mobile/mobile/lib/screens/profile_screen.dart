import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Loading...";
  String email = "...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    var data = await ApiService.getUserProfile(widget.userId);
    if (data != null) {
      if (mounted) {
        setState(() {
          fullName = data['fullName'];
          email = data['email'];
          _isLoading = false;
        });
      }
    }
  }

  // CHANGE PASSWORD
  void _showChangePasswordDialog() {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (passController.text.isNotEmpty) {
                bool success = await ApiService.changePassword(widget.userId, passController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Password Updated Successfully" : "Failed to update"),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  // MANAGE PETS
  void _showManagePetsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    var pet = await ApiService.getPetData(widget.userId);
    if (!mounted) return;
    Navigator.pop(context);

    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No pet found.")),
      );
      return;
    }

    final nameCtrl = TextEditingController(text: pet['petName']);
    final breedCtrl = TextEditingController(text: pet['breed']);
    final ageCtrl = TextEditingController(text: pet['age'].toString());
    final weightCtrl = TextEditingController(text: pet['weight'].toString());
    String species = pet['species'] ?? 'Dog';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Pet Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Pet Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: breedCtrl,
              decoration: const InputDecoration(
                labelText: "Breed",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age (Yrs)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Weight (kg)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4081),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  bool success = await ApiService.updatePetDetails(
                    pet['_id'],
                    {
                      "petName": nameCtrl.text,
                      "breed": breedCtrl.text,
                      "age": double.tryParse(ageCtrl.text) ?? 0,
                      "weight": double.tryParse(weightCtrl.text) ?? 0,
                      "species": species,
                    },
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Pet Details Updated!" : "Update Failed"),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGOUT
  void _handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFF4081),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 15),
            Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 40),

            _buildOptionCard(
              icon: Icons.lock,
              title: "Change Password",
              color: Colors.blue,
              onTap: _showChangePasswordDialog,
            ),
            _buildOptionCard(
              icon: Icons.pets,
              title: "Manage Pets",
              color: Colors.orange,
              onTap: _showManagePetsDialog,
            ),
            _buildOptionCard(
              icon: Icons.logout,
              title: "Log Out",
              color: Colors.red,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}