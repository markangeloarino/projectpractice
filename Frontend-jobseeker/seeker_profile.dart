import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../screen_login.dart';
import 'profile/step_1_personal_information.dart';
import 'profile/step_2_employment_status.dart';
import 'profile/step_3_job_preference.dart';
import 'profile/step_4_language_dialect.dart';
import 'profile/step_5_educational_background.dart';
import 'profile/step_6_certification_training.dart';
import 'profile/step_7_eligibility_license.dart';
import 'profile/step_8_work_experience.dart';
import 'profile/step_9_other_skills.dart';
import 'widget/app_bar.dart';

class ScreenSeekerProfile extends StatefulWidget {
  const ScreenSeekerProfile({super.key});

  @override
  State<ScreenSeekerProfile> createState() => _ScreenSeekerProfileState();
}

class _ScreenSeekerProfileState extends State<ScreenSeekerProfile> {
  int _currentStep = 0;

  final List<String> _sideBarSteps = [
    "Personal information",
    "Employment status/type",
    "Job preferences",
    "Language/dialects proficiency",
    "Educational background",
    "Technical/Vocational and Other Training",
    "Eligibility/Professional License",
    "Work experience",
    "Other skills acquired without certificate",
  ];

  final List<String> _menuSteps = [
    "Personal information",
    "Employment status/type",
    "Job preferences",
    "Language/dialects proficiency (check if applicable)",
    "Educational background",
    "Technical/Vocational and Other Training (include courses taken as part of college education)",
    "Eligibility/Professional License",
    "Work experience (Limit to 10-year period, start with the most recent employment)",
    "Other skills acquired without certificate",
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SeekerAppBar(
        onLogout: () {
          authProvider.currentUser = null;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ScreenLogin()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP SECTION: Profile Header
            _buildTopHeader(user),
            _buildLabel(
              "INSTRUCTIONS: Please fill out the form legible in block letters. Do not leave any items unanswered. Indicate \"N/A\" if not applicable",
            ), // BOTTOM SECTION: Sidebar and Form
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sidebar Navigation
                      _buildSidebar(),
                      const SizedBox(width: 24),
                      // Form Content Area
                      Expanded(child: _buildFormContent(user)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopHeader(Map<String, dynamic>? user) {
    // Determine Display Name safely
    String firstName = user?['first_name'] ?? 'User';
    String lastName = user?['last_name'] ?? '';
    String fullName = "$firstName $lastName".trim().toUpperCase();

    // Default contact values if not found in db
    String email = user?['email'] ?? 'No email provided';
    String phone = user?['contact_number'] ?? 'No phone provided';
    // Address currently isn't in your DB schema for job seekers, adding fallback
    String address = user?['address'] ?? 'Please update your address';

    return Column(
      children: [
        // Light Blue Banner Info
        Container(
          width: double.infinity,
          color: const Color(0xFFBCE6EB), // Light cyan/blue background
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.cyan.shade300, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(
                        0xFF3E3A35,
                      ), // Dark brown/grey
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 60,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // User Details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildContactRow(Icons.location_on_outlined, address),
                      const SizedBox(height: 6),
                      _buildContactRow(Icons.alternate_email, email),
                      const SizedBox(height: 6),
                      _buildContactRow(Icons.phone_android, phone),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Faint divider line
        Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black87),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_sideBarSteps.length, (index) {
          bool isActive = _currentStep == index;
          return InkWell(
            onTap: () {
              setState(() {
                _currentStep = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF42A5F5)
                    : Colors.white, // Blue if active
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Text(
                _sideBarSteps[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormContent(Map<String, dynamic>? user) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grey Title Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            color: const Color(0xFFE9ECEF), // Light grey header
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _menuSteps[_currentStep].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Step ${_currentStep + 1} of ${_menuSteps.length}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          // Form Fields inside the active step
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: _currentStep == 0
                ? PersonalInformation(user: user)
                : _currentStep == 1
                ? EmploymentStatus(user: user)
                : _currentStep == 2
                ? JobPreferences(user: user)
                : _currentStep == 3
                ? LanguageDialect(user: user)
                : _currentStep == 4
                ? EducationalBackground(user: user)
                : _currentStep == 5
                ? CertificationTraining(user: user)
                : _currentStep == 6
                ? EligibilityLicense(user: user)
                : _currentStep == 7
                ? WorkExperience(user: user)
                : _currentStep == 8
                ? OtherSkills(user: user)
                : const Center(
                    child: Text(
                      "Form fields for this section are under construction.",
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
