import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmploymentStatus extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EmploymentStatus({super.key, required this.user});

  @override
  State<EmploymentStatus> createState() => _EmploymentStatusState();
}

class _EmploymentStatusState extends State<EmploymentStatus> {
  // --- EMPLOYMENT STATUS CONTROLLERS & STATE ---
  String _mainEmploymentStatus = "Unemployed";
  String _employedCategory = "Employed";
  String _selfEmployedType = "";
  final TextEditingController _selfEmployedOthersCtrl = TextEditingController();
  final TextEditingController _monthsLookingCtrl = TextEditingController();
  String _unemployedReason = "";
  final TextEditingController _unemployedCountryCtrl = TextEditingController();
  final TextEditingController _unemployedOthersCtrl = TextEditingController();
  String _isOfw = "No";
  final TextEditingController _ofwCountryCtrl = TextEditingController();
  String _isFormerOfw = "No";
  final TextEditingController _formerOfwCountryCtrl = TextEditingController();
  final TextEditingController _formerOfwReturnCtrl = TextEditingController();
  String _hasOfwFamily = "No";
  String _ofwFamilyMember = "";
  final TextEditingController _ofwFamilyCountryCtrl = TextEditingController();
  String _is4ps = "No";
  final TextEditingController _fourpsIdCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true; // Added to handle initial data load

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadEmploymentData();
  }

  Future<void> _loadEmploymentData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/employment-status');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data.isNotEmpty && mounted) {
          setState(() {
            _mainEmploymentStatus = data['main_status'] ?? "Unemployed";
            _employedCategory = data['employed_category'] ?? "Employed";
            _selfEmployedType = data['self_employed_type'] ?? "";
            _selfEmployedOthersCtrl.text = data['self_employed_others'] ?? "";
            _monthsLookingCtrl.text = data['months_looking']?.toString() ?? "";
            _unemployedReason = data['unemployed_reason'] ?? "";
            _unemployedCountryCtrl.text = data['unemployed_country'] ?? "";
            _unemployedOthersCtrl.text = data['unemployed_others'] ?? "";
            _isOfw = data['is_ofw'] ?? "No";
            _ofwCountryCtrl.text = data['ofw_country'] ?? "";
            _isFormerOfw = data['is_former_ofw'] ?? "No";
            _formerOfwCountryCtrl.text = data['former_ofw_country'] ?? "";
            _formerOfwReturnCtrl.text = data['former_ofw_return'] ?? "";
            _hasOfwFamily = data['has_ofw_family'] ?? "No";
            _ofwFamilyMember = data['ofw_family_member'] ?? "";
            _ofwFamilyCountryCtrl.text = data['ofw_family_country'] ?? "";
            _is4ps = data['is_4ps'] ?? "No";
            _fourpsIdCtrl.text = data['fourps_id'] ?? "";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load saved employment data."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
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
        "main_status": _mainEmploymentStatus,
        "employed_category": _employedCategory,
        "self_employed_type": _selfEmployedType,
        "self_employed_others": _selfEmployedOthersCtrl.text.trim(),
        "months_looking": int.tryParse(_monthsLookingCtrl.text.trim()),
        "unemployed_reason": _unemployedReason,
        "unemployed_country": _unemployedCountryCtrl.text.trim(),
        "unemployed_others": _unemployedOthersCtrl.text.trim(),
        "is_ofw": _isOfw,
        "ofw_country": _ofwCountryCtrl.text.trim(),
        "is_former_ofw": _isFormerOfw,
        "former_ofw_country": _formerOfwCountryCtrl.text.trim(),
        "former_ofw_return": _formerOfwReturnCtrl.text.trim(),
        "has_ofw_family": _hasOfwFamily,
        "ofw_family_member": _ofwFamilyMember,
        "ofw_family_country": _ofwFamilyCountryCtrl.text.trim(),
        "is_4ps": _is4ps,
        "fourps_id": _fourpsIdCtrl.text.trim(),
      };

      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/employment-status');

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
            const SnackBar(
              content: Text("Employment Status saved!"),
              backgroundColor: Colors.green,
            ),
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
    _selfEmployedOthersCtrl.dispose();
    _monthsLookingCtrl.dispose();
    _unemployedCountryCtrl.dispose();
    _unemployedOthersCtrl.dispose();
    _ofwCountryCtrl.dispose();
    _formerOfwCountryCtrl.dispose();
    _formerOfwReturnCtrl.dispose();
    _ofwFamilyCountryCtrl.dispose();
    _fourpsIdCtrl.dispose();
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
        // --- MAIN STATUS: EMPLOYED VS UNEMPLOYED ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT COLUMN: EMPLOYED
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _mainEmploymentStatus == "Employed"
                        ? Colors.grey.shade300
                        : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadio(
                      "Employed (Currently Working)",
                      "Employed",
                      _mainEmploymentStatus,
                      (v) => setState(() => _mainEmploymentStatus = v!),
                    ),
                    const Divider(),
                    if (_mainEmploymentStatus == "Employed") ...[
                      _buildRadio(
                        "Employed",
                        "Employed",
                        _employedCategory,
                        (v) => setState(() => _employedCategory = v!),
                      ),
                      _buildRadio(
                        "Self-Employed (Please specify)",
                        "Self-Employed",
                        _employedCategory,
                        (v) => setState(() => _employedCategory = v!),
                      ),

                      if (_employedCategory == "Self-Employed")
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRadio(
                                "Fisherman/Fisherfolk",
                                "Fisherman",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Vendor/Retailer",
                                "Vendor",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Transport",
                                "Transport",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Freelancer",
                                "Freelancer",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Home-based worker",
                                "Home-based",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Domestic Worker",
                                "Domestic",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Artisan/Craft Worker",
                                "Artisan",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              _buildRadio(
                                "Others (Please specify):",
                                "Others",
                                _selfEmployedType,
                                (v) => setState(() => _selfEmployedType = v!),
                              ),
                              if (_selfEmployedType == "Others")
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: _buildGreyTextFieldController(
                                    _selfEmployedOthersCtrl,
                                    hint: "Specify here...",
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // RIGHT COLUMN: UNEMPLOYED
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _mainEmploymentStatus == "Unemployed"
                        ? Colors.grey.shade300
                        : Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRadio(
                      "Unemployed",
                      "Unemployed",
                      _mainEmploymentStatus,
                      (v) => setState(() => _mainEmploymentStatus = v!),
                    ),
                    const Divider(),
                    if (_mainEmploymentStatus == "Unemployed") ...[
                      _buildLabel(
                        "How long have you been looking for work? (months)",
                      ),
                      _buildGreyTextFieldController(
                        _monthsLookingCtrl,
                        isNumber: true,
                        hint: "e.g. 3",
                      ),
                      const SizedBox(height: 15),

                      _buildRadio(
                        "New Entrant / Fresh Graduate",
                        "New Entrant",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Finished Contract",
                        "Finished Contract",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Resigned",
                        "Resigned",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Retired",
                        "Retired",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Terminated/Laid off due to calamity",
                        "Calamity",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Terminated/Laid off (local)",
                        "Laid off local",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      _buildRadio(
                        "Terminated/Laid off (abroad)",
                        "Laid off abroad",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      if (_unemployedReason == "Laid off abroad")
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 30.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: _buildGreyTextFieldController(
                            _unemployedCountryCtrl,
                            hint: "Specify country...",
                          ),
                        ),
                      _buildRadio(
                        "Others, please specify:",
                        "Others",
                        _unemployedReason,
                        (v) => setState(() => _unemployedReason = v!),
                      ),
                      if (_unemployedReason == "Others")
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 8.0),
                          child: _buildGreyTextFieldController(
                            _unemployedOthersCtrl,
                            hint: "Specify reason...",
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(),
        const SizedBox(height: 20),

        // --- OFW SECTION ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Are you an OFW?"),
                  Row(
                    children: [
                      _buildRadio(
                        "Yes",
                        "Yes",
                        _isOfw,
                        (v) => setState(() => _isOfw = v!),
                      ),
                      const SizedBox(width: 20),
                      _buildRadio(
                        "No",
                        "No",
                        _isOfw,
                        (v) => setState(() => _isOfw = v!),
                      ),
                    ],
                  ),
                  if (_isOfw == "Yes") ...[
                    const SizedBox(height: 10),
                    _buildLabel("Specify country"),
                    _buildGreyTextFieldController(_ofwCountryCtrl),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Are you a former OFW?"),
                  Row(
                    children: [
                      _buildRadio(
                        "Yes",
                        "Yes",
                        _isFormerOfw,
                        (v) => setState(() => _isFormerOfw = v!),
                      ),
                      const SizedBox(width: 20),
                      _buildRadio(
                        "No",
                        "No",
                        _isFormerOfw,
                        (v) => setState(() => _isFormerOfw = v!),
                      ),
                    ],
                  ),
                  if (_isFormerOfw == "Yes") ...[
                    const SizedBox(height: 10),
                    _buildLabel("Latest Country of deployment"),
                    _buildGreyTextFieldController(_formerOfwCountryCtrl),
                    const SizedBox(height: 10),
                    _buildLabel("Month and year of return to Philippines"),
                    _buildGreyTextFieldController(
                      _formerOfwReturnCtrl,
                      hint: "e.g. March 2022",
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // --- OFW IN FAMILY SECTION ---
        _buildLabel("Is there an OFW in the family?"),
        Row(
          children: [
            _buildRadio(
              "Yes",
              "Yes",
              _hasOfwFamily,
              (v) => setState(() => _hasOfwFamily = v!),
            ),
            const SizedBox(width: 20),
            _buildRadio(
              "No",
              "No",
              _hasOfwFamily,
              (v) => setState(() => _hasOfwFamily = v!),
            ),
          ],
        ),
        if (_hasOfwFamily == "Yes") ...[
          const SizedBox(height: 10),
          _buildLabel("If yes, Who?"),
          Wrap(
            spacing: 15,
            children: [
              _buildRadio(
                "Spouse",
                "Spouse",
                _ofwFamilyMember,
                (v) => setState(() => _ofwFamilyMember = v!),
              ),
              _buildRadio(
                "Parent",
                "Parent",
                _ofwFamilyMember,
                (v) => setState(() => _ofwFamilyMember = v!),
              ),
              _buildRadio(
                "Sibling",
                "Sibling",
                _ofwFamilyMember,
                (v) => setState(() => _ofwFamilyMember = v!),
              ),
              _buildRadio(
                "Son",
                "Son",
                _ofwFamilyMember,
                (v) => setState(() => _ofwFamilyMember = v!),
              ),
              _buildRadio(
                "Daughter",
                "Daughter",
                _ofwFamilyMember,
                (v) => setState(() => _ofwFamilyMember = v!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildLabel("Specify country"),
          _buildGreyTextFieldController(_ofwFamilyCountryCtrl),
        ],

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // --- 4Ps BENEFICIARY ---
        _buildLabel("Are you a 4Ps beneficiary?"),
        Row(
          children: [
            _buildRadio(
              "Yes",
              "Yes",
              _is4ps,
              (v) => setState(() => _is4ps = v!),
            ),
            const SizedBox(width: 20),
            _buildRadio("No", "No", _is4ps, (v) => setState(() => _is4ps = v!)),
          ],
        ),
        if (_is4ps == "Yes") ...[
          const SizedBox(height: 10),
          _buildLabel("If yes, please provide Household ID No."),
          _buildGreyTextFieldController(_fourpsIdCtrl, isNumber: true),
        ],

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

  // Helper for creating consistent radio buttons
  Widget _buildRadio(
    String title,
    String value,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          activeColor: const Color(0xFF1D3A8A), // primaryAccent equivalent
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        GestureDetector(
          onTap: () => onChanged(value),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
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
  } // Updated text field builder to support hints and number keyboards

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