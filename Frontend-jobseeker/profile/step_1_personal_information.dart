import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:nagajob/Frontend-jobseeker/widget/form_style.dart';

class PersonalInformation extends StatefulWidget {
  final Map<String, dynamic>? user;
  const PersonalInformation({super.key, required this.user});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  // --- CONTROLLERS ---
  final TextEditingController _surnameCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _middleNameCtrl = TextEditingController();
  final TextEditingController _suffixCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _religionCtrl = TextEditingController();

  // Address Controllers
  final TextEditingController _presentAddressCtrl = TextEditingController();
  final TextEditingController _houseNoCtrl = TextEditingController();
  final TextEditingController _barangayCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _provinceCtrl = TextEditingController();

  final TextEditingController _tinCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _otherDisabilityCtrl = TextEditingController();

  String _isFirstTimeJobseeker = "Yes";
  String? _civilStatus;
  String? _selectedSex;
  List<String> _selectedDisabilities = [];

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _isFirstTimeJobseeker = (data['is_first_time_jobseeker'] == 1)
                ? "Yes"
                : "No";
            _surnameCtrl.text = data['last_name'] ?? '';
            _firstNameCtrl.text = data['first_name'] ?? '';
            _middleNameCtrl.text = data['middle_name'] ?? '';
            _suffixCtrl.text = data['suffix'] ?? '';
            _dobCtrl.text = data['date_of_birth'] ?? '';
            _selectedSex = data['sex'];
            _ageCtrl.text = data['age']?.toString() ?? '';
            _religionCtrl.text = data['religion'] ?? '';
            _civilStatus = data['civil_status'];

            // Map all 5 address fields
            _presentAddressCtrl.text = data['present_address'] ?? '';
            _houseNoCtrl.text = data['house_no'] ?? '';
            _barangayCtrl.text = data['barangay'] ?? '';
            _cityCtrl.text = data['city'] ?? '';
            _provinceCtrl.text = data['province'] ?? '';

            _tinCtrl.text = data['tin'] ?? '';
            _heightCtrl.text = data['height'] ?? '';

            if (data['disabilities'] != null &&
                data['disabilities'].toString().isNotEmpty) {
              _selectedDisabilities = data['disabilities']
                  .toString()
                  .split(', ')
                  .toList();
            } else {
              _selectedDisabilities = ["None"];
            }

            _otherDisabilityCtrl.text = data['other_disability'] ?? '';
            _contactCtrl.text = data['contact_number'] ?? '';
            _emailCtrl.text = data['email'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not load latest profile data."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // ==========================================
  // HTTP PUT TO DATABASE
  // ==========================================
  Future<void> _saveToDatabase() async {
    setState(() => _isLoading = true);

    try {
      final seekerId = widget.user?['seeker_id'];
      if (seekerId == null) throw Exception("No logged-in user found.");

      final Map<String, dynamic> formData = {
        "is_first_time_jobseeker": _isFirstTimeJobseeker == "Yes" ? 1 : 0,
        "surname": _surnameCtrl.text.trim(),
        "first_name": _firstNameCtrl.text.trim(),
        "middle_name": _middleNameCtrl.text.trim(),
        "suffix": _suffixCtrl.text.trim(),
        "date_of_birth": _dobCtrl.text.trim(),
        "sex": _selectedSex,
        "age": int.tryParse(_ageCtrl.text.trim()) ?? 0,
        "religion": _religionCtrl.text.trim(),
        "civil_status": _civilStatus,

        // Save all 5 address fields
        "present_address": _presentAddressCtrl.text.trim(),
        "house_no": _houseNoCtrl.text.trim(),
        "barangay": _barangayCtrl.text.trim(),
        "city": _cityCtrl.text.trim(),
        "province": _provinceCtrl.text.trim(),

        "tin": _tinCtrl.text.trim(),
        "height": _heightCtrl.text.trim(),
        "disabilities": _selectedDisabilities.join(", "),
        "other_disability": _otherDisabilityCtrl.text.trim(),
        "contact_number": _contactCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
      };

      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId');

      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(formData),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Personal Information successfully saved!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Failed to save data. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _surnameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _suffixCtrl.dispose();
    _dobCtrl.dispose();
    _emailCtrl.dispose();
    _contactCtrl.dispose();
    _ageCtrl.dispose();
    _religionCtrl.dispose();

    _presentAddressCtrl.dispose();
    _houseNoCtrl.dispose();
    _barangayCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();

    _tinCtrl.dispose();
    _heightCtrl.dispose();
    _otherDisabilityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Are you a first-time Jobseeker?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 24),
            RadioButton(
              title: "Yes",
              value: "Yes",
              groupValue: _isFirstTimeJobseeker,
              onChanged: (v) => setState(() => _isFirstTimeJobseeker = v!),
            ),
            const SizedBox(width: 20),
            RadioButton(
              title: "No",
              value: "No",
              groupValue: _isFirstTimeJobseeker,
              onChanged: (v) => setState(() => _isFirstTimeJobseeker = v!),
            ),
          ],
        ),
        const Divider(height: 30, color: Colors.black54, thickness: 1.5),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "SURNAME"),
                  GreyTextField(controller: _surnameCtrl),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "FIRST NAME"),
                  GreyTextField(controller: _firstNameCtrl),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "MIDDLE NAME"),
                  GreyTextField(controller: _middleNameCtrl),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "SUFFIX (Ex. Sr., Jr., III)"),
                  GreyTextField(controller: _suffixCtrl),
                ],
              ),
            ),
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "DATE OF BIRTH (mm/dd/yy)"),
                  GreyTextField(controller: _dobCtrl, hint: "mm/dd/yyyy"),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "SEX"),
                  SelectDropDown(
                    items: ["Male", "Female"],
                    currentValue: _selectedSex,
                    onChanged: (v) => setState(() => _selectedSex = v),
                    hint: "Select Sex",
                  ),
                ],
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "AGE"),
                  GreyTextField(controller: _ageCtrl, isNumber: true),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "RELIGION"),
                  GreyTextField(controller: _religionCtrl),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "CIVIL STATUS"),
                  SelectDropDown(
                    items: ["Single", "Married", "Widowed", "Separated"],
                    currentValue: _civilStatus,
                    onChanged: (v) => setState(() => _civilStatus = v),
                    hint: "Select Civil Status",
                  ),
                ],
              ),
            ),
          ],
        ),

        // --- FULL PRESENT ADDRESS FIELD ---
        BuildLabel(text: "PRESENT ADDRESS (Full Address)"),
        GreyTextField(
          controller: _presentAddressCtrl,
          hint: "Enter your full address...",
        ),
        const SizedBox(height: 10),

        // --- THE 4 SPECIFIC ADDRESS FIELDS ---
        Row(
          children: [
            Expanded(
              child: GreyTextField(
                controller: _houseNoCtrl,
                hint: "House No./Street/Village",
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GreyTextField(controller: _barangayCtrl, hint: "Barangay"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GreyTextField(
                controller: _cityCtrl,
                hint: "Municipality/City",
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GreyTextField(controller: _provinceCtrl, hint: "Province"),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "TIN"),
                  GreyTextField(controller: _tinCtrl),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "HEIGHT (FT.)"),
                  GreyTextField(controller: _heightCtrl),
                ],
              ),
            ),
          ],
        ),

        BuildLabel(text: "DISABILITY"),
        Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children:
              [
                "None",
                "Visual",
                "Speech",
                "Mental",
                "Hearing",
                "Physical",
                "Others",
              ].map((disability) {
                bool isSelected = _selectedDisabilities.contains(disability);

                return BuildCheckbox(
                  title: disability,
                  value: isSelected,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        if (disability == "None") {
                          _selectedDisabilities.clear();
                          _selectedDisabilities.add("None");
                        } else {
                          _selectedDisabilities.remove("None");
                          _selectedDisabilities.add(disability);
                        }
                      } else {
                        _selectedDisabilities.remove(disability);
                      }
                    });
                  },
                );
              }).toList(),
        ),
        if (_selectedDisabilities.contains("Others")) ...[
          const SizedBox(height: 12),
          GreyTextField(
            controller: _otherDisabilityCtrl,
            hint: "Please specify disability...",
          ),
        ],

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "CONTACT NUMBER/S"),
                  GreyTextField(controller: _contactCtrl, isNumber: true),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "E-MAIL"),
                  GreyTextField(controller: _emailCtrl, isReadOnly: true),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
        const Divider(color: Colors.black12, thickness: 1),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: _isLoading ? null : () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Color(0xFF3B82F6)),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : _saveToDatabase,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1D3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "SAVE CHANGES",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
