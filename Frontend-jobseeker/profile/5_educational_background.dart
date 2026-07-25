import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EducationalBackground extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EducationalBackground({super.key, required this.user});

  @override
  State<EducationalBackground> createState() => _EducationalBackgroundState();
}

class _EducationalBackgroundState extends State<EducationalBackground> {
  // --- EDUCATIONAL BACKGROUND STATE ---
  String _currentlyInSchool = "No";
  String _secondaryType = "K12"; // "Non-K12" or "K12"

  // Elementary
  final TextEditingController _elemSchoolCtrl = TextEditingController();
  final TextEditingController _elemYearGradCtrl = TextEditingController();
  final TextEditingController _elemLevelCtrl = TextEditingController();
  final TextEditingController _elemYearLastCtrl = TextEditingController();

  // Secondary
  final TextEditingController _secSchoolCtrl = TextEditingController();
  final TextEditingController _secCourseCtrl = TextEditingController();
  final TextEditingController _secYearGradCtrl = TextEditingController();
  final TextEditingController _secLevelCtrl = TextEditingController();
  final TextEditingController _secYearLastCtrl = TextEditingController();

  // Tertiary
  final TextEditingController _tertSchoolCtrl = TextEditingController();
  final TextEditingController _tertCourseCtrl = TextEditingController();
  final TextEditingController _tertYearGradCtrl = TextEditingController();
  final TextEditingController _tertLevelCtrl = TextEditingController();
  final TextEditingController _tertYearLastCtrl = TextEditingController();

  // Graduate Studies
  final TextEditingController _gradSchoolCtrl = TextEditingController();
  final TextEditingController _gradCourseCtrl = TextEditingController();
  final TextEditingController _gradYearGradCtrl = TextEditingController();
  final TextEditingController _gradLevelCtrl = TextEditingController();
  final TextEditingController _gradYearLastCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }

  Future<void> _loadEducationData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/educational-background');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _currentlyInSchool = data['currently_in_school'] ?? "No";
            _secondaryType = data['secondary_type'] ?? "K12";

            // Elementary
            _elemSchoolCtrl.text = data['elem_school'] ?? '';
            _elemYearGradCtrl.text = data['elem_year_grad'] ?? '';
            _elemLevelCtrl.text = data['elem_level'] ?? '';
            _elemYearLastCtrl.text = data['elem_year_last'] ?? '';

            // Secondary
            _secSchoolCtrl.text = data['sec_school'] ?? '';
            _secCourseCtrl.text = data['sec_course'] ?? '';
            _secYearGradCtrl.text = data['sec_year_grad'] ?? '';
            _secLevelCtrl.text = data['sec_level'] ?? '';
            _secYearLastCtrl.text = data['sec_year_last'] ?? '';

            // Tertiary
            _tertSchoolCtrl.text = data['tert_school'] ?? '';
            _tertCourseCtrl.text = data['tert_course'] ?? '';
            _tertYearGradCtrl.text = data['tert_year_grad'] ?? '';
            _tertLevelCtrl.text = data['tert_level'] ?? '';
            _tertYearLastCtrl.text = data['tert_year_last'] ?? '';

            // Graduate
            _gradSchoolCtrl.text = data['grad_school'] ?? '';
            _gradCourseCtrl.text = data['grad_course'] ?? '';
            _gradYearGradCtrl.text = data['grad_year_grad'] ?? '';
            _gradLevelCtrl.text = data['grad_level'] ?? '';
            _gradYearLastCtrl.text = data['grad_year_last'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load educational background."), backgroundColor: Colors.red),
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
        "currently_in_school": _currentlyInSchool,
        "secondary_type": _secondaryType,
        
        "elem_school": _elemSchoolCtrl.text.trim(), "elem_year_grad": _elemYearGradCtrl.text.trim(), "elem_level": _elemLevelCtrl.text.trim(), "elem_year_last": _elemYearLastCtrl.text.trim(),
        "sec_school": _secSchoolCtrl.text.trim(), "sec_course": _secCourseCtrl.text.trim(), "sec_year_grad": _secYearGradCtrl.text.trim(), "sec_level": _secLevelCtrl.text.trim(), "sec_year_last": _secYearLastCtrl.text.trim(),
        "tert_school": _tertSchoolCtrl.text.trim(), "tert_course": _tertCourseCtrl.text.trim(), "tert_year_grad": _tertYearGradCtrl.text.trim(), "tert_level": _tertLevelCtrl.text.trim(), "tert_year_last": _tertYearLastCtrl.text.trim(),
        "grad_school": _gradSchoolCtrl.text.trim(), "grad_course": _gradCourseCtrl.text.trim(), "grad_year_grad": _gradYearGradCtrl.text.trim(), "grad_level": _gradLevelCtrl.text.trim(), "grad_year_last": _gradYearLastCtrl.text.trim(),
      };

      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/educational-background');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Educational Background saved!"), backgroundColor: Colors.green));
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
    _elemSchoolCtrl.dispose(); _elemYearGradCtrl.dispose(); _elemLevelCtrl.dispose(); _elemYearLastCtrl.dispose();
    _secSchoolCtrl.dispose(); _secCourseCtrl.dispose(); _secYearGradCtrl.dispose(); _secLevelCtrl.dispose(); _secYearLastCtrl.dispose();
    _tertSchoolCtrl.dispose(); _tertCourseCtrl.dispose(); _tertYearGradCtrl.dispose(); _tertLevelCtrl.dispose(); _tertYearLastCtrl.dispose();
    _gradSchoolCtrl.dispose(); _gradCourseCtrl.dispose(); _gradYearGradCtrl.dispose(); _gradLevelCtrl.dispose(); _gradYearLastCtrl.dispose();
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
        const SizedBox(height: 16),
        // --- HEADER: CURRENTLY IN SCHOOL ---
        Row(
          children: [
            const Text(
              "Currently in School?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 24),
            _buildRadio(
              "YES",
              "Yes",
              _currentlyInSchool,
              (v) => setState(() => _currentlyInSchool = v!),
            ),
            const SizedBox(width: 16),
            _buildRadio(
              "NO",
              "No",
              _currentlyInSchool,
              (v) => setState(() => _currentlyInSchool = v!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),

        // --- TABLE HEADERS ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "LEVEL",
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "NAME OF SCHOOL\n(State in Full / No Acronym)",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "COURSE\n(State in Full / No Acronym)",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    "YEAR\nGRADUATED",
                    textAlign: TextAlign.center,
                    style: _headerStyle(),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("IF UNDERGRADUATE", style: _headerStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Center(
                            child: Text(
                              "LEVEL\nREACHED",
                              textAlign: TextAlign.center,
                              style: _subHeaderStyle(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "YEAR LAST\nATTENDED",
                            textAlign: TextAlign.center,
                            style: _subHeaderStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.black26, thickness: 1.5),

        // --- ROW 1: ELEMENTARY ---
        _buildEducRow(
          levelWidget: const Text(
            "Elementary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          schoolCtrl: _elemSchoolCtrl,
          courseWidget: Container(
            height: 44, // Matches the height of TextFields
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              "N/A",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          yearGradCtrl: _elemYearGradCtrl,
          levelReachedCtrl: _elemLevelCtrl,
          yearLastCtrl: _elemYearLastCtrl,
        ),
        const Divider(color: Colors.black12),

        // --- ROW 2: SECONDARY ---
        _buildEducRow(
          levelWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Secondary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              _buildRadio(
                "Non-K12",
                "Non-K12",
                _secondaryType,
                (v) => setState(() => _secondaryType = v!),
              ),
              _buildRadio(
                "K12",
                "K12",
                _secondaryType,
                (v) => setState(() => _secondaryType = v!),
              ),
            ],
          ),
          schoolCtrl: _secSchoolCtrl,
          courseWidget: _buildGreyTextFieldController(
            _secCourseCtrl,
            hint: "Strand if K12:",
          ),
          yearGradCtrl: _secYearGradCtrl,
          levelReachedCtrl: _secLevelCtrl,
          yearLastCtrl: _secYearLastCtrl,
        ),
        const Divider(color: Colors.black12),

        // --- ROW 3: TERTIARY ---
        _buildEducRow(
          levelWidget: const Text(
            "Tertiary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          schoolCtrl: _tertSchoolCtrl,
          courseWidget: _buildGreyTextFieldController(_tertCourseCtrl),
          yearGradCtrl: _tertYearGradCtrl,
          levelReachedCtrl: _tertLevelCtrl,
          yearLastCtrl: _tertYearLastCtrl,
        ),
        const Divider(color: Colors.black12),

        // --- ROW 4: GRADUATE STUDIES ---
        _buildEducRow(
          levelWidget: const Text(
            "Graduate Studies/\nPost-graduate",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          schoolCtrl: _gradSchoolCtrl,
          courseWidget: _buildGreyTextFieldController(_gradCourseCtrl),
          yearGradCtrl: _gradYearGradCtrl,
          levelReachedCtrl: _gradLevelCtrl,
          yearLastCtrl: _gradYearLastCtrl,
        ),
        const Divider(color: Colors.black12),

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

  // Helper for Headers
  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
      fontSize: 12,
    );
  }

  // Helper for Sub-Headers
  TextStyle _subHeaderStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
      fontSize: 11,
    );
  }

  // Helper for creating consistent radio buttons
  Widget _buildRadio(
    String title,
    String value,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(value),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFF1D3A8A),
              onChanged: onChanged,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Helper for generating the Educational Background table rows perfectly aligned
  Widget _buildEducRow({
    required Widget levelWidget,
    required TextEditingController schoolCtrl,
    required Widget courseWidget,
    required TextEditingController yearGradCtrl,
    required TextEditingController levelReachedCtrl,
    required TextEditingController yearLastCtrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 12.0),
              child: levelWidget,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildGreyTextFieldController(schoolCtrl),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: courseWidget,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildGreyTextFieldController(
                yearGradCtrl,
                isNumber: true,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildGreyTextFieldController(levelReachedCtrl),
                  ),
                ),
                Expanded(
                  child: _buildGreyTextFieldController(
                    yearLastCtrl,
                    isNumber: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated text field builder to guarantee consistent heights
  Widget _buildGreyTextFieldController(
    TextEditingController controller, {
    String? hint,
    bool isNumber = false,
  }) {
    return Container(
      height: 44, // Fixed height keeps the tabular rows aligned
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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