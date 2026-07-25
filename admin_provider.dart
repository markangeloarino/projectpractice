import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminProvider with ChangeNotifier {
  final String apiUrl = "http://127.0.0.1:3000/api"; // Change to your IP if using an emulator
  List<dynamic> staffList = [];
  bool isLoading = false;

  Future<void> fetchStaff() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$apiUrl/admin/staff'));
      if (response.statusCode == 200) {
        staffList = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching staff: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> addStaff(String name, String email, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/admin/staff'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'role': role}),
      );
      if (response.statusCode == 201) fetchStaff();
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> updateStaff(int id, String name, String email, String role) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/admin/staff/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'role': role}),
      );
      if (response.statusCode == 200) fetchStaff();
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(int id) async {
    try {
      final response = await http.put(Uri.parse('$apiUrl/admin/staff/$id/reset-password'));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }

  Future<Map<String, dynamic>> deleteStaff(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/admin/staff/$id'));
      if (response.statusCode == 200) fetchStaff();
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Connection error'};
    }
  }
}