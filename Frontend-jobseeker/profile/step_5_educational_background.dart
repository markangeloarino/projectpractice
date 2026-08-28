import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nagajob/Frontend-jobseeker/widget/form_style.dart';

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
      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse(
        '$baseUrl/api/seekers/$seekerId/educational-background',
      );

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
          const SnackBar(
            content: Text("Could not load educational background."),
            backgroundColor: Colors.red,
          ),
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

        "elem_school": _elemSchoolCtrl.text.trim(),
        "elem_year_grad": _elemYearGradCtrl.text.trim(),
        "elem_level": _elemLevelCtrl.text.trim(),
        "elem_year_last": _elemYearLastCtrl.text.trim(),
        "sec_school": _secSchoolCtrl.text.trim(),
        "sec_course": _secCourseCtrl.text.trim(),
        "sec_year_grad": _secYearGradCtrl.text.trim(),
        "sec_level": _secLevelCtrl.text.trim(),
        "sec_year_last": _secYearLastCtrl.text.trim(),
        "tert_school": _tertSchoolCtrl.text.trim(),
        "tert_course": _tertCourseCtrl.text.trim(),
        "tert_year_grad": _tertYearGradCtrl.text.trim(),
        "tert_level": _tertLevelCtrl.text.trim(),
        "tert_year_last": _tertYearLastCtrl.text.trim(),
        "grad_school": _gradSchoolCtrl.text.trim(),
        "grad_course": _gradCourseCtrl.text.trim(),
        "grad_year_grad": _gradYearGradCtrl.text.trim(),
        "grad_level": _gradLevelCtrl.text.trim(),
        "grad_year_last": _gradYearLastCtrl.text.trim(),
      };

      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse(
        '$baseUrl/api/seekers/$seekerId/educational-background',
      );

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
              content: Text("Educational Background saved!"),
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
    _elemSchoolCtrl.dispose();
    _elemYearGradCtrl.dispose();
    _elemLevelCtrl.dispose();
    _elemYearLastCtrl.dispose();
    _secSchoolCtrl.dispose();
    _secCourseCtrl.dispose();
    _secYearGradCtrl.dispose();
    _secLevelCtrl.dispose();
    _secYearLastCtrl.dispose();
    _tertSchoolCtrl.dispose();
    _tertCourseCtrl.dispose();
    _tertYearGradCtrl.dispose();
    _tertLevelCtrl.dispose();
    _tertYearLastCtrl.dispose();
    _gradSchoolCtrl.dispose();
    _gradCourseCtrl.dispose();
    _gradYearGradCtrl.dispose();
    _gradLevelCtrl.dispose();
    _gradYearLastCtrl.dispose();
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
        // --- HEADER: CURRENTLY IN SCHOOL ---
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildLabel(text: "Currently in School?"),
            const SizedBox(width: 24),
             Wrap(
        spacing: 10,
        children: [
          _radioPill(
            label: 'Non-K12 (old curriculum)',
            value: 'Non-K12',
            groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!),
          ),
          _radioPill(
            label: 'K12 (SHS strand)',
            value: 'K12',
            groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!),
          ),
        ],
      ),
            RadioButton(
              title: "YES",
              value: "Yes",
              groupValue: _currentlyInSchool,
              onChanged: (v) => setState(() => _currentlyInSchool = v!),
            ),
            const SizedBox(width: 16),
            RadioButton(
              title: "NO",
              value: "No",
              groupValue: _currentlyInSchool,
              onChanged: (v) => setState(() => _currentlyInSchool = v!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),

        const SizedBox(height: 8),

        // --- ROW 2: SECONDARY ---
        _educCard(
          title: 'Elementary',
          iconBgColor: const Color(0xFFDCFCE7),
          schoolCtrl: _elemSchoolCtrl,
          naForCourse: true,
          yearGradCtrl: _elemYearGradCtrl,
          levelReachedCtrl: _elemLevelCtrl,
          yearLastCtrl: _elemYearLastCtrl,
        ),

        const SizedBox(height: 16),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),
        _educCard(
          title: 'Secondary (High School)',
          iconBgColor: const Color(0xFFDCFCE7),
          extras: _secondaryExtras(),
          schoolCtrl: _secSchoolCtrl,
          courseOverride: TextFormField(
            controller: _secCourseCtrl,
            decoration: _inputDeco(
              _secondaryType == 'K12'
                  ? 'e.g. Science, Technology, Engineering & Mathematics (STEM)'
                  : 'e.g. General Secondary Education',
            ),
          ),
          yearGradCtrl: _secYearGradCtrl,
          levelReachedCtrl: _secLevelCtrl,
          yearLastCtrl: _secYearLastCtrl,
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),
        _educCard(
          title: 'Tertiary (College)',
          iconBgColor: const Color(0xFFDCFCE7),
          schoolCtrl: _tertSchoolCtrl,
          courseCtrl: _tertCourseCtrl,
          yearGradCtrl: _tertYearGradCtrl,
          levelReachedCtrl: _tertLevelCtrl,
          yearLastCtrl: _tertYearLastCtrl,
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.black54, thickness: 1.5),
        const SizedBox(height: 8),
        _educCard(
          title: 'Graduate Studies / Post-graduate',
          iconBgColor: const Color(0xFFDCFCE7),
          schoolCtrl: _gradSchoolCtrl,
          courseCtrl: _gradCourseCtrl,
          yearGradCtrl: _gradYearGradCtrl,
          levelReachedCtrl: _gradLevelCtrl,
          yearLastCtrl: _gradYearLastCtrl,
        ),

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
              onPressed: _isLoading
                  ? null
                  : () {
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

  // ── Education level card ───────────────────────────────────────────
  Widget _educCard({
    required String title,
    required Color iconBgColor,
    Widget? extras, // e.g. K12 toggle for Secondary
    required TextEditingController schoolCtrl,
    bool naForCourse = false,
    Widget? courseOverride, // custom course field
    TextEditingController? courseCtrl,
    required TextEditingController yearGradCtrl,
    required TextEditingController levelReachedCtrl,
    required TextEditingController yearLastCtrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card header ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _primary,
            // borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // ── Card body ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional extras (K12 toggle, etc.)
              if (extras != null) ...[extras, const SizedBox(height: 16)],

              // School name
              BuildLabel(text: 'Name of School'),
              TextFormField(
                controller: schoolCtrl,
                decoration: _inputDeco(
                  'Write the complete name — no abbreviations or acronyms',
                ),
              ),

              // Course / strand
              if (!naForCourse) BuildLabel(text: 'Course / Strand / Program'),
              if (!naForCourse)
                if (!naForCourse)
                  courseOverride ??
                      TextFormField(
                        controller: courseCtrl,
                        decoration: _inputDeco(
                          'Write in full — no abbreviations or acronyms',
                        ),
                      ),

              // Year graduated
              BuildLabel(text: 'Year Graduated'),
              TextFormField(
                controller: yearGradCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDeco(
                  'Leave blank if you did not graduate from this level',
                ),
              ),

              // ── Undergraduate sub-section ────────────────────
              _sectionDivider('IF YOU DID NOT GRADUATE FROM THIS LEVEL'),

              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, size: 15, color: _accent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fill in the two fields below only if you stopped or did not '
                        'finish this education level. Otherwise, leave them blank.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E40AF),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildLabel(text: 'Highest Level Reached'),
                        TextFormField(
                          controller: levelReachedCtrl,
                          decoration: _inputDeco('e.g. Grade 10'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildLabel(text: 'Year Last Attended'),
                        TextFormField(
                          controller: yearLastCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('e.g. 2016'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String placeholder) => InputDecoration(
    hintText: placeholder,
    hintStyle: const TextStyle(color: _hintColor, fontSize: 13),
    filled: true,
    fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _accent, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    isDense: true,
  );

  // Styled radio chip pill
  Widget _radioPill({
    required String label,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final bool selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _primary : _fieldBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? Colors.white : _hintColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Secondary K12/Non-K12 extras widget ──────────────────────────
  Widget _secondaryExtras() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BuildLabel(text: 'What type of Secondary education did you attend?'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 10,
        children: [
          _radioPill(
            label: 'Non-K12 (old curriculum)',
            value: 'Non-K12',
            groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!),
          ),
          _radioPill(
            label: 'K12 (SHS strand)',
            value: 'K12',
            groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!),
          ),
        ],
      ),
    ],
  );
  // Divider with label (used inside cards to separate sections)
  Widget _sectionDivider(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    ),
  );
  // ── Design tokens ──────────────────────────────────────────────────
  static const Color _primary = Color(0xFF1D3A8A);
  static const Color _accent = Color(0xFF3B82F6); 
  static const Color _fieldBg = Color(0xFFF0F2F8);
  static const Color _labelColor = Color(0xFF374151);
  static const Color _hintColor = Color(0xFF9CA3AF);
}
