import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- DATA MODEL FOR DYNAMIC ROWS ---
class WorkExperienceRecord {
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController positionCtrl = TextEditingController();
  final TextEditingController dateFromCtrl = TextEditingController();
  final TextEditingController dateToCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
}

class WorkExperience extends StatefulWidget {
  final Map<String, dynamic>? user;
  const WorkExperience({super.key, required this.user});

  @override
  State<WorkExperience> createState() => _WorkExperienceState();
}

class _WorkExperienceState extends State<WorkExperience> {
  // Initializing with exactly 3 rows as requested
  final List<WorkExperienceRecord> _workExperiences = List.generate(
    3,
    (_) => WorkExperienceRecord(),
  );

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadWorkData();
  }

  Future<void> _loadWorkData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/work-experiences');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
        if (mounted) {
          setState(() {
            // Populate up to 3 rows based on database records
            for (int i = 0; i < data.length && i < 3; i++) {
              _workExperiences[i].companyCtrl.text = data[i]['company_name'] ?? '';
              _workExperiences[i].addressCtrl.text = data[i]['address'] ?? '';
              _workExperiences[i].positionCtrl.text = data[i]['position'] ?? '';
              _workExperiences[i].dateFromCtrl.text = data[i]['date_from'] ?? '';
              _workExperiences[i].dateToCtrl.text = data[i]['date_to'] ?? '';
              _workExperiences[i].statusCtrl.text = data[i]['status'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load work experience."), backgroundColor: Colors.red),
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

      // Package only the rows that have a company name filled out
      final List<Map<String, dynamic>> workData = [];
      for (var record in _workExperiences) {
        if (record.companyCtrl.text.trim().isNotEmpty) {
          workData.add({
            "company_name": record.companyCtrl.text.trim(),
            "address": record.addressCtrl.text.trim(),
            "position": record.positionCtrl.text.trim(),
            "date_from": record.dateFromCtrl.text.trim(),
            "date_to": record.dateToCtrl.text.trim(),
            "status": record.statusCtrl.text.trim(),
          });
        }
      }

      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/work-experiences');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"experiences": workData}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Work Experience saved!"), backgroundColor: Colors.green));
        }
      } else {
        throw Exception("Status: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (var record in _workExperiences) {
      record.companyCtrl.dispose();
      record.addressCtrl.dispose();
      record.positionCtrl.dispose();
      record.dateFromCtrl.dispose();
      record.dateToCtrl.dispose();
      record.statusCtrl.dispose();
    }
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
        _buildLabel(
          "VII. WORK EXPERIENCE (Limit to 10-year period, start with the most recent employment)",
        ),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),

        // --- TABULAR HEADERS ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "COMPANY NAME",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "ADDRESS\n(City/Municipality)",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "POSITION",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "INCLUSIVE DATES\n(mm/dd/yyyy)",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(
                    "STATUS\n(Perm, Contract, etc.)",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.black26, thickness: 1.5),
        const SizedBox(height: 8),

        // --- DYNAMIC DATA ROWS ---
        for (int i = 0; i < _workExperiences.length; i++)
          _buildWorkRow(_workExperiences[i]),

        const SizedBox(height: 30),

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

  Widget _buildWorkRow(WorkExperienceRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildGreyTextFieldController(record.companyCtrl),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildGreyTextFieldController(record.addressCtrl),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildGreyTextFieldController(record.positionCtrl),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: _buildGreyTextFieldController(
                      record.dateFromCtrl,
                      hint: "From",
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildGreyTextFieldController(
                      record.dateToCtrl,
                      hint: "To",
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildGreyTextFieldController(record.statusCtrl),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      fontSize: 11,
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

  Widget _buildGreyTextFieldController(
    TextEditingController controller, {
    String? hint,
  }) {
    return Container(
      height: 44, 
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          isDense: true,
        ),
      ),
    );
  }
}