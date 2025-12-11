import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'pet_onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    // 1. Login to get User ID
    var userData = await ApiService.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    if (userData != null) {
      if (!mounted) return;

      // 2. Fetch Pet Data to see if they have a pet
      var petData = await ApiService.getPetData(userData['id']);

      if (!mounted) return;

      if (petData != null) {
        // HAS PET -> Go to Dashboard
        // FIX: Pass userName instead of petId to match DashboardScreen constructor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen(
                  userId: userData['id'],
                  userName: userData['name']
              )
          ),
        );
      } else {
        // NO PET -> Go to Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PetOnboardingScreen(
                  userId: userData['id'],
                  userName: userData['name']
              )
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Invalid Email or Password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Color(0xFFFF4081)),
            const SizedBox(height: 20),
            const Text("TailTime Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4081), foregroundColor: Colors.white),
                onPressed: _handleLogin,
                child: const Text("LOGIN"),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text("Register Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}