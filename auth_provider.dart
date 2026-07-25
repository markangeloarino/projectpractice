import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? currentUser; // Holds the logged-in user's data

  // Replace with your actual backend URL when hosting
  final String apiUrl = 'http://localhost:3000/api'; 

  // REGISTER
  Future<bool> register(String first, String last, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': first,
          'lastName': last,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        return true; // Registration success
      } else {
        errorMessage = jsonDecode(response.body)['error'];
      }
    } catch (e) {
      errorMessage = "Connection error";
    }
    
    isLoading = false;
    notifyListeners();
    return false;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Save the user data in Flutter memory
        currentUser = jsonDecode(response.body)['user'];
        isLoading = false;
        notifyListeners();
        return true; 
      } else {
        errorMessage = jsonDecode(response.body)['error'];
      }
    } catch (e) {
      errorMessage = "Connection error";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

// Inside auth_provider.dart
  Future<String?> staffLogin(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/staff/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        currentUser = jsonDecode(response.body)['user'];
        isLoading = false;
        notifyListeners();
        
        // Return the specific role to the UI
        return currentUser!['role']; 
      } else {
        errorMessage = jsonDecode(response.body)['error'];
      }
    } catch (e) {
      errorMessage = "Connection error";
    }

    isLoading = false;
    notifyListeners();
    return null; // Login failed
  }

  
}

