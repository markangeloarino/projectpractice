import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- DATA MODELS FOR STATIC ROWS ---
class EligibilityRecord {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
}

class LicenseRecord {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController();
}

class EligibilityLicense extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EligibilityLicense({super.key, required this.user});

  @override
  State<EligibilityLicense> createState() => _EligibilityLicenseState();
}

class _EligibilityLicenseState extends State<EligibilityLicense> {
  // Initialize with exactly 3 rows for each section
  final List<EligibilityRecord> _eligibilities = List.generate(3, (_) => EligibilityRecord());
  final List<LicenseRecord> _licenses = List.generate(3, (_) => LicenseRecord());

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadEligibilityLicenseData();
  }

  Future<void> _loadEligibilityLicenseData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/eligibilities-licenses');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List eligList = data['eligibilities'] ?? [];
        final List licList = data['licenses'] ?? [];

        if (mounted) {
          setState(() {
            // Populate up to 3 Eligibilities
            for (int i = 0; i < eligList.length && i < 3; i++) {
              _eligibilities[i].nameCtrl.text = eligList[i]['eligibility_name'] ?? '';
              _eligibilities[i].dateCtrl.text = eligList[i]['date_taken'] ?? '';
            }
            // Populate up to 3 Licenses
            for (int i = 0; i < licList.length && i < 3; i++) {
              _licenses[i].nameCtrl.text = licList[i]['license_name'] ?? '';
              _licenses[i].dateCtrl.text = licList[i]['valid_until'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load eligibilities/licenses."), backgroundColor: Colors.red),
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

      // Package only rows that have a name filled out
      final List<Map<String, dynamic>> eligData = [];
      for (var e in _eligibilities) {
        if (e.nameCtrl.text.trim().isNotEmpty) {
          eligData.add({
            "eligibility_name": e.nameCtrl.text.trim(),
            "date_taken": e.dateCtrl.text.trim(),
          });
        }
      }

      final List<Map<String, dynamic>> licData = [];
      for (var l in _licenses) {
        if (l.nameCtrl.text.trim().isNotEmpty) {
          licData.add({
            "license_name": l.nameCtrl.text.trim(),
            "valid_until": l.dateCtrl.text.trim(),
          });
        }
      }

      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/eligibilities-licenses');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "eligibilities": eligData,
          "licenses": licData
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data saved successfully!"), backgroundColor: Colors.green));
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
    for (var e in _eligibilities) {
      e.nameCtrl.dispose();
      e.dateCtrl.dispose();
    }
    for (var l in _licenses) {
      l.nameCtrl.dispose();
      l.dateCtrl.dispose();
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
        // --- ELIGIBILITY SECTION ---
        _buildLabel("ELIGIBILITY (Civil Service)"),
        for (int i = 0; i < _eligibilities.length; i++)
          _buildEligibilityRow(i, _eligibilities[i]),
        
        const SizedBox(height: 32),

        // --- LICENSE SECTION ---
        _buildLabel("PROFESSIONAL LICENSE (PRC)"),
        for (int i = 0; i < _licenses.length; i++)
          _buildLicenseRow(i, _licenses[i]),
          
        const SizedBox(height: 40),

        // ====================================
        // BOTTOM BUTTON
        // ====================================
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

  Widget _buildEligibilityRow(int index, EligibilityRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              "${index + 1}.",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildGreyTextFieldController(
              record.nameCtrl,
              hint: "Eligibility",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _buildGreyTextFieldController(
              record.dateCtrl,
              hint: "Date Taken (mm/dd/yyyy)",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseRow(int index, LicenseRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              "${index + 1}.",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildGreyTextFieldController(
              record.nameCtrl,
              hint: "Professional License (PRC)",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _buildGreyTextFieldController(
              record.dateCtrl,
              hint: "Valid Until (mm/dd/yyyy)",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
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
    IconData? icon,
    String? hint,
    bool isNumber = false,
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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