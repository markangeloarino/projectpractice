import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VacancyProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  // Add this list to hold the jobs we pull from the database
  List<dynamic> activeJobs = [];
  List<dynamic> myApplications = []; // Holds the jobs the seeker applied for
  List<dynamic> employers = []; // NEW: List to hold employers

  final String apiUrl = 'http://localhost:3000/api';

  Future<bool> encodeVacancy(Map<String, dynamic> jobData) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/vacancies'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(jobData),
      );

      

if (response.statusCode == 201) {
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Unmask the real error coming from the Node.js server!
        final responseData = jsonDecode(response.body);
        errorMessage = responseData['error'] ?? "Failed to encode job (Unknown Error).";
        return false;
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  List<dynamic> allApplications = []; // NEW: For admin

  Future<void> fetchAllApplications() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$apiUrl/admin/applications'));
      if (response.statusCode == 200) {
        allApplications = jsonDecode(response.body);
        errorMessage = null;
      } else {
        errorMessage = "Failed to load applications.";
      }
    } catch (e) { errorMessage = "Server connection failed."; }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateApplicationStatus(int appId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/admin/applications/$appId/status'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'status': status}),
      );
      if (response.statusCode == 200) {
        // Update local list instantly
        final index = allApplications.indexWhere((app) => app['application_id'] == appId);
        if (index != -1) {
          allApplications[index]['status'] = status;
          notifyListeners();
        }
        return true;
      }
    } catch (e) { errorMessage = "Update failed."; }
    return false;
  }

  // Add this function to fetch the public jobs
  Future<void> fetchVacancies() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiUrl/vacancies'));

      if (response.statusCode == 200) {
        activeJobs = jsonDecode(response.body);
        errorMessage = null;
      } else {
        errorMessage = "Failed to load jobs.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> applyForJob(int seekerId, int vacancyId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/applications'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'seeker_id': seekerId,
          'vacancy_id': vacancyId,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Success
      } else if (response.statusCode == 409) {
        errorMessage = "You have already applied for this job.";
        return false;
      } else {
        errorMessage = "Failed to submit application.";
        return false;
      }
    } catch (e) {
      errorMessage = "Server error while applying.";
      return false;
    }
  }

  // Fetch the current job seeker's application history
  Future<void> fetchMyApplications(int seekerId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiUrl/applications/seeker/$seekerId'));

      if (response.statusCode == 200) {
        myApplications = jsonDecode(response.body);
        errorMessage = null;
      } else {
        errorMessage = "Failed to load your applications.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
  }

  // Function to delete/close a job posting
  Future<bool> deleteVacancy(int vacancyId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/vacancies/$vacancyId'));

      if (response.statusCode == 200) {
        // Remove it from the local list instantly so the UI updates without needing a refresh
        activeJobs.removeWhere((job) => job['vacancy_id'] == vacancyId);
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to delete job.";
        return false;
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
      return false;
    }
  }

  Future<bool> registerEmployer(Map<String, String> employerData) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/employers'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(employerData),
      );

      if (response.statusCode == 201) {
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = jsonDecode(response.body)['error'] ?? "Failed to register employer.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // Update an existing employer
  Future<bool> updateEmployer(int employerId, Map<String, dynamic> employerData) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/employers/$employerId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(employerData),
      );

      if (response.statusCode == 200) {
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to update employer.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete an employer
  Future<bool> deleteEmployer(int employerId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/employers/$employerId'));

      if (response.statusCode == 200) {
        employers.removeWhere((emp) => emp['employer_id'] == employerId);
        notifyListeners();
        return true;
      } else if (response.statusCode == 400) {
        // This catches the custom backend error blocking deletion
        errorMessage = jsonDecode(response.body)['error'];
        return false;
      } else {
        errorMessage = "Failed to delete employer.";
        return false;
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
      return false;
    }
  }

  Future<void> fetchEmployers() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiUrl/employers'));
      if (response.statusCode == 200) {
        employers = jsonDecode(response.body);
        errorMessage = null;
      } else {
        errorMessage = "Failed to load employers.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
  }
  


  Future<bool> updateVacancy(int vacancyId, Map<String, dynamic> jobData) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/vacancies/$vacancyId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(jobData),
      );

      if (response.statusCode == 200) {
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to update job.";
      }
    } catch (e) {
      errorMessage = "Server connection failed.";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
