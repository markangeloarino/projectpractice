import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/6_certification_training.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/5_educational_background.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/7_eligibility_license.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/2_employment_status.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/3_job_preference.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/4_language_dialect.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/9_other_skills.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/1_personal_information.dart';
import 'package:neis_cap/Frontend-jobseeker/profile/8_work_experience.dart';
import 'package:neis_cap/Frontend-jobseeker/seeker_dashboard.dart';
import 'package:neis_cap/auth_provider.dart';
import 'package:neis_cap/screen_login.dart';
import 'package:provider/provider.dart';

class ScreenSeekerProfile extends StatefulWidget {
  const ScreenSeekerProfile({super.key});

  @override
  State<ScreenSeekerProfile> createState() => _ScreenSeekerProfileState();
}

class _ScreenSeekerProfileState extends State<ScreenSeekerProfile> {
  int _currentStep = 0;

  // --- EXISTING CONTROLLERS ---
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  String _selectedSex = "Male";

  // --- NEW CONTROLLERS (Based on image) ---
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _religionCtrl = TextEditingController();
  final TextEditingController _houseNoCtrl = TextEditingController();
  final TextEditingController _barangayCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _provinceCtrl = TextEditingController();
  final TextEditingController _tinCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _otherDisabilityCtrl = TextEditingController();

  bool _isFirstTimeJobseeker = true;
  String _civilStatus = "Single";
  String _disability = "None";

  final List<String> _menuSteps = [
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = authProvider.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        toolbarHeight: 85,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Removes default edge padding so it aligns perfectly
        centerTitle: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Matches the body container
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ), // Matches body padding
            child: Row(
              children: [
                // Official Seals / Logos
                Image.asset('assets/naga.png', height: 70, fit: BoxFit.contain),
                const SizedBox(width: 10),
                Image.asset('assets/peso.png', height: 70, fit: BoxFit.contain),
                const SizedBox(width: 15),
                // Logo Text
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Naga Job",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Dashboard Navigation Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenSeekerDashboard(),
                      ),
                    );
                  },
                  child: const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Profile Navigation Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenSeekerProfile(),
                      ),
                    );
                  },
                  child: const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Dropdown Menu triggered by the Profile Picture Circle (Now only for Logout)
                PopupMenuButton<String>(
                  offset: const Offset(
                    0,
                    50,
                  ), // Pushes the dropdown slightly below the app bar
                  tooltip: 'Account Menu',
                  onSelected: (String value) {
                    if (value == 'logout') {
                      authProvider.currentUser = null;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenLogin(),
                        ),
                      );
                    }
                  },
                  // The Profile Picture Circle
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF0D47A1),
                      ), // Using an icon until a real image is added
                    ),
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
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
        children: List.generate(_menuSteps.length, (index) {
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
                _menuSteps[index],
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

  // Updated text field builder to support hints and number keyboards
  Widget _buildGreyTextFieldController(
    TextEditingController controller, {
    IconData? icon,
    String? hint,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          isDense: true,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        ),
      ),
    );
  }

  // Reusable dropdown builder for Civil Status & Disability
  Widget _buildDropdown(
    List<String> items,
    String currentValue,
    Function(String?) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  // --- HELPER WIDGETS FOR FORM STYLING ---

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

  Widget _buildGreyTextField(
    String initialValue, {
    bool isDropdown = false,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFE9ECEF,
        ), // The specific light grey fill color from the image
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: isDropdown, // If it's a dropdown, prevent typing
        decoration: InputDecoration(
          border: InputBorder.none, // Hide default underline
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          isDense: true,
          suffixIcon: isDropdown
              ? const Icon(Icons.keyboard_arrow_down, color: Colors.black54)
              : (icon != null ? Icon(icon, color: Colors.black54) : null),
        ),
      ),
    );
  }
}
