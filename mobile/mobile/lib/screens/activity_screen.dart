import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ----------------------------------------------------------------------
  // IMPORTANT NETWORK CONFIGURATION
  // ----------------------------------------------------------------------
  // Check your IP Address using 'ipconfig' in command prompt if the app doesn't connect.
  static const String baseUrl = "http://192.168.1.4:3000/api";

  // ==============================================================================
  // 1. AUTHENTICATION
  // ==============================================================================

  static Future<void> registerUser(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      print("Error connecting to server: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['user'];
      }
      return null;
    } catch (e) {
      print("Error connecting to server: $e");
      return null;
    }
  }

  // ==============================================================================
  // 2. PET MANAGEMENT
  // ==============================================================================

  static Future<Map<String, dynamic>?> getPetData(String userId) async {
    final url = Uri.parse('$baseUrl/pets/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching pet: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> addPet(String userId, String name, String species, String breed, String age, String weight) async {
    final url = Uri.parse('$baseUrl/pets/add');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ownerId": userId,
          "petName": name,
          "species": species,
          "breed": breed,
          "age": age,
          "weight": weight
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error adding pet: $e");
      return null;
    }
  }

  static Future<bool> updatePetDetails(String petId, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/pets/update/$petId');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating pet: $e");
      return false;
    }
  }

  static Future<void> toggleTask(String userId, String taskName, bool status) async {
    final url = Uri.parse('$baseUrl/pets/toggle-task');
    try {
      await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "taskName": taskName,
          "status": status
        }),
      );
    } catch (e) {
      print("Error toggling task: $e");
    }
  }

  // ==============================================================================
  // 3. ACTIVITY LOGGING & CHARTS
  // ==============================================================================

  static Future<void> logActivity(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/pets/log-activity');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
    } catch (e) {
      print("Error logging activity: $e");
    }
  }

  static Future<List<dynamic>> getWeeklyStats(String userId, String type) async {
    final url = Uri.parse('$baseUrl/pets/weekly-stats/$userId/$type');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching stats: $e");
      return [];
    }
  }

  // ==============================================================================
  // 4. CARE CALENDAR (EVENTS)
  // ==============================================================================

  static Future<List<dynamic>> getEvents(String userId) async {
    final url = Uri.parse('$baseUrl/events/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  static Future<bool> addEvent(String userId, String title, DateTime date, String type) async {
    final url = Uri.parse('$baseUrl/events/add');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "title": title,
          "date": date.toIso8601String(),
          "type": type,
        }),
      );
      return true;
    } catch (e) {
      print("Error adding event: $e");
      return false;
    }
  }

  static Future<bool> deleteEvent(String eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting event: $e");
      return false;
    }
  }

  // ==============================================================================
  // 5. MEDICAL HUB
  // ==============================================================================

  static Future<List<dynamic>> getMedicalRecords(String userId) async {
    final url = Uri.parse('$baseUrl/medical/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching medical records: $e");
      return [];
    }
  }

  static Future<bool> addMedicalRecord(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/medical/add');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return true;
    } catch (e) {
      print("Error adding medical record: $e");
      return false;
    }
  }

  // ==============================================================================
  // 6. USER PROFILE & SETTINGS
  // ==============================================================================

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  static Future<void> updateSettings(String userId, Map<String, dynamic> settings) async {
    final url = Uri.parse('$baseUrl/user/settings');
    try {
      await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "settings": settings
        }),
      );
    } catch (e) {
      print("Error updating settings: $e");
    }
  }

  static Future<bool> changePassword(String userId, String newPassword) async {
    final url = Uri.parse('$baseUrl/user/change-password');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "newPassword": newPassword
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error changing password: $e");
      return false;
    }
  }
}