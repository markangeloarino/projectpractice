import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nagajob/Frontend-jobseeker/widget/form_style.dart';

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
      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
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
          const SnackBar(
            content: Text("Could not load saved employment data."),
            backgroundColor: Colors.red,
          ),
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
                    RadioButton(
                      title: "Emplyed (Currently Working)",
                      value: "Employed",
                      groupValue: _mainEmploymentStatus,
                      onChanged: (v) =>
                          setState(() => _mainEmploymentStatus = v!),
                    ),
                    const Divider(),
                    if (_mainEmploymentStatus == "Employed") ...[
                      RadioButton(
                        title: "Employed",
                        value: "Employed",
                        groupValue: _employedCategory,
                        onChanged: (v) =>
                            setState(() => _employedCategory = v!),
                      ),
                      RadioButton(
                        title: "Self-Employed (Please specify)",
                        value: "Self-Employed",
                        groupValue: _employedCategory,
                        onChanged: (v) =>
                            setState(() => _employedCategory = v!),
                      ),

                      if (_employedCategory == "Self-Employed")
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RadioButton(
                                title: "Fisherman/Fisherfolk",
                                value: "Fisherman",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Vendor/Retailer",
                                value: "Vendor",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Transport",
                                value: "Transport",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Freelancer",
                                value: "Freelancer",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Home-based worker",
                                value: "Home-based",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Domestic Worker",
                                value: "Domestic",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Artisan/Craft Worker",
                                value: "Artisan",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              RadioButton(
                                title: "Others (Please specify):",
                                value: "Others",
                                groupValue: _selfEmployedType,
                                onChanged: (v) =>
                                    setState(() => _selfEmployedType = v!),
                              ),
                              if (_selfEmployedType == "Others")
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: GreyTextField(
                                    controller: _selfEmployedOthersCtrl,
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
                    RadioButton(
                      title: "Unemployed",
                      value: "Unemployed",
                      groupValue: _mainEmploymentStatus,
                      onChanged: (v) =>
                          setState(() => _mainEmploymentStatus = v!),
                    ),
                    const Divider(),
                    if (_mainEmploymentStatus == "Unemployed") ...[
                      BuildLabel(
                        text:
                            "How long have you been looking for work? (months)",
                      ),
                      GreyTextField(
                        controller: _monthsLookingCtrl,
                        isNumber: true,
                        hint: "e.g. 3",
                      ),
                      const SizedBox(height: 15),

                      RadioButton(
                        title: "New Entrant / Fresh Graduate",
                        value: "New Entrant",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Finished Contract",
                        value: "Finished Contract",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Resigned",
                        value: "Resigned",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Retired",
                        value: "Retired",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Terminated/Laid off due to calamity",
                        value: "Calamity",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Terminated/Laid off (local)",
                        value: "Laid off local",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      RadioButton(
                        title: "Terminated/Laid off (abroad)",
                        value: "Laid off abroad",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      if (_unemployedReason == "Laid off abroad")
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 30.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: GreyTextField(
                            controller: _unemployedCountryCtrl,
                            hint: "Specify country...",
                          ),
                        ),
                      RadioButton(
                        title: "Others, please specify:",
                        value: "Others",
                        groupValue: _unemployedReason,
                        onChanged: (v) =>
                            setState(() => _unemployedReason = v!),
                      ),
                      if (_unemployedReason == "Others")
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 8.0),
                          child: GreyTextField(
                            controller: _unemployedOthersCtrl,
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
                  BuildLabel(text: "Are you an OFW?"),
                  Row(
                    children: [
                      RadioButton(
                        title: "Yes",
                        value: "Yes",
                        groupValue: _isOfw,
                        onChanged: (v) => setState(() => _isOfw = v!),
                      ),
                      const SizedBox(width: 20),
                      RadioButton(
                        title: "No",
                        value: "No",
                        groupValue: _isOfw,
                        onChanged: (v) => setState(() => _isOfw = v!),
                      ),
                    ],
                  ),
                  if (_isOfw == "Yes") ...[
                    const SizedBox(height: 10),
                    BuildLabel(text: "Specify country"),
                    GreyTextField(controller: _ofwCountryCtrl),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildLabel(text: "Are you a former OFW?"),
                  Row(
                    children: [
                      RadioButton(
                        title: "Yes",
                        value: "Yes",
                        groupValue: _isFormerOfw,
                        onChanged: (v) => setState(() => _isFormerOfw = v!),
                      ),
                      const SizedBox(width: 20),
                      RadioButton(
                        title: "No",
                        value: "No",
                        groupValue: _isFormerOfw,
                        onChanged: (v) => setState(() => _isFormerOfw = v!),
                      ),
                    ],
                  ),
                  if (_isFormerOfw == "Yes") ...[
                    const SizedBox(height: 10),
                    BuildLabel(text: "Latest Country of deployment"),
                    GreyTextField(controller: _formerOfwCountryCtrl),
                    const SizedBox(height: 10),
                    BuildLabel(text: "Month and year of return to Philippines"),
                    GreyTextField(
                      controller: _formerOfwReturnCtrl,
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
        BuildLabel(text: "Is there an OFW in the family?"),
        Row(
          children: [
            RadioButton(
              title: "Yes",
              value: "Yes",
              groupValue: _hasOfwFamily,
              onChanged: (v) => setState(() => _hasOfwFamily = v!),
            ),
            const SizedBox(width: 20),
            RadioButton(
              title: "No",
              value: "No",
              groupValue: _hasOfwFamily,
              onChanged: (v) => setState(() => _hasOfwFamily = v!),
            ),
          ],
        ),
        if (_hasOfwFamily == "Yes") ...[
          const SizedBox(height: 10),
          BuildLabel(text: "If yes, Who?"),
          Wrap(
            spacing: 15,
            children: [
              RadioButton(
                title: "Spouse",
                value: "Spouse",
                groupValue: _ofwFamilyMember,
                onChanged: (v) => setState(() => _ofwFamilyMember = v!),
              ),
              RadioButton(
                title: "Parent",
                value: "Parent",
                groupValue: _ofwFamilyMember,
                onChanged: (v) => setState(() => _ofwFamilyMember = v!),
              ),
              RadioButton(
                title: "Sibling",
                value: "Sibling",
                groupValue: _ofwFamilyMember,
                onChanged: (v) => setState(() => _ofwFamilyMember = v!),
              ),
              RadioButton(
                title: "Son",
                value: "Son",
                groupValue: _ofwFamilyMember,
                onChanged: (v) => setState(() => _ofwFamilyMember = v!),
              ),
              RadioButton(
                title: "Daughter",
                value: "Daughter",
                groupValue: _ofwFamilyMember,
                onChanged: (v) => setState(() => _ofwFamilyMember = v!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BuildLabel(text: "Specify country"),
          GreyTextField(controller: _ofwFamilyCountryCtrl),
        ],

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // --- 4Ps BENEFICIARY ---
        BuildLabel(text: "Are you a 4Ps beneficiary?"),
        Row(
          children: [
            RadioButton(
              title: "Yes",
              value: "Yes",
              groupValue: _is4ps,
              onChanged: (v) => setState(() => _is4ps = v!),
            ),
            const SizedBox(width: 20),
            RadioButton(
              title: "No",
              value: "No",
              groupValue: _is4ps,
              onChanged: (v) => setState(() => _is4ps = v!),
            ),
          ],
        ),
        if (_is4ps == "Yes") ...[
          const SizedBox(height: 10),
          BuildLabel(text: "If yes, please provide Household ID No."),
          GreyTextField(controller: _fourpsIdCtrl, isNumber: true),
        ],

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
}
