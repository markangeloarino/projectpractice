import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JobPreferences extends StatefulWidget {
  final Map<String, dynamic>? user;
  const JobPreferences({super.key, required this.user});

  @override
  State<JobPreferences> createState() => _JobPreferencesState();
}

class _JobPreferencesState extends State<JobPreferences> {
  // --- JOB PREFERENCE CONTROLLERS & STATE ---
  bool _isPartTime = false;
  bool _isFullTime = false;
  bool _isLocal = false;
  bool _isOverseas = false;

  final TextEditingController _jobTitle1Ctrl = TextEditingController();
  final TextEditingController _jobTitle2Ctrl = TextEditingController();
  final TextEditingController _jobTitle3Ctrl = TextEditingController();

  final TextEditingController _company1Ctrl = TextEditingController();
  final TextEditingController _company2Ctrl = TextEditingController();
  final TextEditingController _company3Ctrl = TextEditingController();

  final TextEditingController _local1Ctrl = TextEditingController();
  final TextEditingController _local2Ctrl = TextEditingController();
  final TextEditingController _local3Ctrl = TextEditingController();

  final TextEditingController _overseas1Ctrl = TextEditingController();
  final TextEditingController _overseas2Ctrl = TextEditingController();
  final TextEditingController _overseas3Ctrl = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true; // Added to handle initial data load

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadPreferencesData();
  }

  Future<void> _loadPreferencesData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/job-preferences');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            // 1. Map Core Preferences
            final core = data['core'];
            if (core != null) {
              _isPartTime = core['is_part_time'] == 1;
              _isFullTime = core['is_full_time'] == 1;
              _isLocal = core['is_local'] == 1;
              _isOverseas = core['is_overseas'] == 1;
            }

            // 2. Map Occupations
            final List occs = data['occupations'] ?? [];
            if (occs.isNotEmpty) {
              _jobTitle1Ctrl.text = occs[0]['job_title'] ?? '';
              _company1Ctrl.text = occs[0]['company_name'] ?? '';
            }
            if (occs.length > 1) {
              _jobTitle2Ctrl.text = occs[1]['job_title'] ?? '';
              _company2Ctrl.text = occs[1]['company_name'] ?? '';
            }
            if (occs.length > 2) {
              _jobTitle3Ctrl.text = occs[2]['job_title'] ?? '';
              _company3Ctrl.text = occs[2]['company_name'] ?? '';
            }

            // 3. Map Locations
            final List locs = data['locations'] ?? [];
            final localLocs = locs.where((l) => l['is_overseas'] == 0).toList();
            final overseasLocs = locs.where((l) => l['is_overseas'] == 1).toList();

            // Fill Local Inputs
            if (localLocs.isNotEmpty) _local1Ctrl.text = localLocs[0]['location_name'] ?? '';
            if (localLocs.length > 1) _local2Ctrl.text = localLocs[1]['location_name'] ?? '';
            if (localLocs.length > 2) _local3Ctrl.text = localLocs[2]['location_name'] ?? '';

            // Fill Overseas Inputs
            if (overseasLocs.isNotEmpty) _overseas1Ctrl.text = overseasLocs[0]['location_name'] ?? '';
            if (overseasLocs.length > 1) _overseas2Ctrl.text = overseasLocs[1]['location_name'] ?? '';
            if (overseasLocs.length > 2) _overseas3Ctrl.text = overseasLocs[2]['location_name'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load saved job preferences."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // ==========================================
  // HTTP POST TO DATABASE
  // ==========================================
  Future<void> _saveToDatabase() async {
    setState(() => _isLoading = true);

    try {
      final seekerId = widget.user?['seeker_id'];
      if (seekerId == null) throw Exception("No logged-in user found.");

      final Map<String, dynamic> formData = {
        "is_part_time": _isPartTime ? 1 : 0,
        "is_full_time": _isFullTime ? 1 : 0,
        "is_local": _isLocal ? 1 : 0,
        "is_overseas": _isOverseas ? 1 : 0,
        "occupations": [
          {"job_title": _jobTitle1Ctrl.text.trim(), "company_name": _company1Ctrl.text.trim()},
          {"job_title": _jobTitle2Ctrl.text.trim(), "company_name": _company2Ctrl.text.trim()},
          {"job_title": _jobTitle3Ctrl.text.trim(), "company_name": _company3Ctrl.text.trim()},
        ],
        "local_locations": [
          _local1Ctrl.text.trim(), _local2Ctrl.text.trim(), _local3Ctrl.text.trim()
        ],
        "overseas_locations": [
          _overseas1Ctrl.text.trim(), _overseas2Ctrl.text.trim(), _overseas3Ctrl.text.trim()
        ],
      };

      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/job-preferences');

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(formData),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Job Preferences saved!"), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception("Status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _jobTitle1Ctrl.dispose();
    _jobTitle2Ctrl.dispose();
    _jobTitle3Ctrl.dispose();
    _company1Ctrl.dispose();
    _company2Ctrl.dispose();
    _company3Ctrl.dispose();
    _local1Ctrl.dispose();
    _local2Ctrl.dispose();
    _local3Ctrl.dispose();
    _overseas1Ctrl.dispose();
    _overseas2Ctrl.dispose();
    _overseas3Ctrl.dispose();
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
        // ==========================================
        // PART 1: PREFERRED OCCUPATION
        // ==========================================
        Row(
          children: [
            _buildLabel("PREFERRED OCCUPATION: "),
            _buildCheckbox(
              "Part-Time",
              _isPartTime,
              (v) => setState(() => _isPartTime = v!),
            ),
            const SizedBox(width: 15),
            _buildCheckbox(
              "Full-Time",
              _isFullTime,
              (v) => setState(() => _isFullTime = v!),
            ),
          ],
        ),
        const Divider(color: Colors.black54, thickness: 1.5),

        // Headers for Occupation
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "JOB TITLE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "COMPANY NAME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Occupation Rows
        _buildOccupationRow("1.", _jobTitle1Ctrl, _company1Ctrl),
        _buildOccupationRow("2.", _jobTitle2Ctrl, _company2Ctrl),
        _buildOccupationRow("3.", _jobTitle3Ctrl, _company3Ctrl),

        const SizedBox(height: 30),

        // ==========================================
        // PART 2: PREFERRED WORK LOCATION
        // ==========================================
        _buildLabel("PREFERRED WORK LOCATION"),
        const Divider(color: Colors.black54, thickness: 1.5),

        // 1. Local (specify cities/municipalities
        _buildCheckbox(
          "Local (specify cities/municipalities)",
          _isLocal,
          (v) => setState(() => _isLocal = v!),
        ),
        const SizedBox(height: 15),

        // Location Rows
        _buildLocalRow("1.", _local1Ctrl),
        _buildLocalRow("2.", _local2Ctrl),
        _buildLocalRow("3.", _local3Ctrl),

        // 2. Overseas (specify countries)
        _buildCheckbox(
          "Overseas (specify countries)",
          _isOverseas,
          (v) => setState(() => _isOverseas = v!),
        ),
        const SizedBox(height: 15),

        // Location Rows
        _buildOversRow("1.", _overseas1Ctrl),
        _buildOversRow("2.", _overseas2Ctrl),
        _buildOversRow("3.", _overseas3Ctrl),

        const SizedBox(height: 40),

        // ====================================
        // BOTTOM BUTTON
        // ====================================
        const SizedBox(height: 40),
        const Divider(color: Colors.black12, thickness: 1),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: _isLoading ? null : () {
                // Handle Back Action
              },
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

  // Helper for generating the Preferred Occupation rows
  Widget _buildOccupationRow(String numLabel, TextEditingController job, TextEditingController comp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              numLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 1, child: _buildGreyTextFieldController(job)),
          const SizedBox(width: 15),
          Expanded(flex: 1, child: _buildGreyTextFieldController(comp)),
        ],
      ),
    );
  }

  // -- LOCAL --
  Widget _buildLocalRow(String numLabel, TextEditingController loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              numLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 1, child: _buildGreyTextFieldController(loc)),
        ],
      ),
    );
  }

  // -- OVERSEAS --
  Widget _buildOversRow(String numLabel, TextEditingController over) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              numLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 1, child: _buildGreyTextFieldController(over)),
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

  // Helper for creating consistent checkboxes
  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1D3A8A),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

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
}