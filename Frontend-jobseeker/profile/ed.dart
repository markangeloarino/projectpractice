import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EducationalBackground1 extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EducationalBackground1({super.key, required this.user});

  @override
  State<EducationalBackground1> createState() => _EducationalBackgroundState();
}

class _EducationalBackgroundState extends State<EducationalBackground1> {
  // ── Design tokens ──────────────────────────────────────────────────
  static const Color _primary    = Color(0xFF1D3A8A);
  static const Color _accent     = Color(0xFF3B82F6);
  static const Color _bg         = Color(0xFFF4F6FB);
  static const Color _cardBg     = Colors.white;
  static const Color _fieldBg    = Color(0xFFF0F2F8);
  static const Color _labelColor = Color(0xFF374151);
  static const Color _hintColor  = Color(0xFF9CA3AF);

  // ── Form state ─────────────────────────────────────────────────────
  String _currentlyInSchool = "No";
  String _secondaryType     = "K12";

  // Elementary
  final TextEditingController _elemSchoolCtrl   = TextEditingController();
  final TextEditingController _elemYearGradCtrl = TextEditingController();
  final TextEditingController _elemLevelCtrl    = TextEditingController();
  final TextEditingController _elemYearLastCtrl = TextEditingController();

  // Secondary
  final TextEditingController _secSchoolCtrl    = TextEditingController();
  final TextEditingController _secCourseCtrl    = TextEditingController();
  final TextEditingController _secYearGradCtrl  = TextEditingController();
  final TextEditingController _secLevelCtrl     = TextEditingController();
  final TextEditingController _secYearLastCtrl  = TextEditingController();

  // Tertiary
  final TextEditingController _tertSchoolCtrl   = TextEditingController();
  final TextEditingController _tertCourseCtrl   = TextEditingController();
  final TextEditingController _tertYearGradCtrl = TextEditingController();
  final TextEditingController _tertLevelCtrl    = TextEditingController();
  final TextEditingController _tertYearLastCtrl = TextEditingController();

  // Graduate
  final TextEditingController _gradSchoolCtrl   = TextEditingController();
  final TextEditingController _gradCourseCtrl   = TextEditingController();
  final TextEditingController _gradYearGradCtrl = TextEditingController();
  final TextEditingController _gradLevelCtrl    = TextEditingController();
  final TextEditingController _gradYearLastCtrl = TextEditingController();

  bool _isLoading  = false;
  bool _isFetching = true;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadEducationData();
  }

  @override
  void dispose() {
    for (final c in [
      _elemSchoolCtrl, _elemYearGradCtrl, _elemLevelCtrl, _elemYearLastCtrl,
      _secSchoolCtrl,  _secCourseCtrl,    _secYearGradCtrl, _secLevelCtrl, _secYearLastCtrl,
      _tertSchoolCtrl, _tertCourseCtrl,   _tertYearGradCtrl, _tertLevelCtrl, _tertYearLastCtrl,
      _gradSchoolCtrl, _gradCourseCtrl,   _gradYearGradCtrl, _gradLevelCtrl, _gradYearLastCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── API calls ──────────────────────────────────────────────────────
  String get _baseUrl => kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  Future<void> _loadEducationData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) { setState(() => _isFetching = false); return; }
    try {
      final url = Uri.parse('$_baseUrl/api/seekers/$seekerId/educational-background');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _currentlyInSchool       = data['currently_in_school'] ?? "No";
            _secondaryType           = data['secondary_type']       ?? "K12";
            _elemSchoolCtrl.text     = data['elem_school']          ?? '';
            _elemYearGradCtrl.text   = data['elem_year_grad']       ?? '';
            _elemLevelCtrl.text      = data['elem_level']           ?? '';
            _elemYearLastCtrl.text   = data['elem_year_last']       ?? '';
            _secSchoolCtrl.text      = data['sec_school']           ?? '';
            _secCourseCtrl.text      = data['sec_course']           ?? '';
            _secYearGradCtrl.text    = data['sec_year_grad']        ?? '';
            _secLevelCtrl.text       = data['sec_level']            ?? '';
            _secYearLastCtrl.text    = data['sec_year_last']        ?? '';
            _tertSchoolCtrl.text     = data['tert_school']          ?? '';
            _tertCourseCtrl.text     = data['tert_course']          ?? '';
            _tertYearGradCtrl.text   = data['tert_year_grad']       ?? '';
            _tertLevelCtrl.text      = data['tert_level']           ?? '';
            _tertYearLastCtrl.text   = data['tert_year_last']       ?? '';
            _gradSchoolCtrl.text     = data['grad_school']          ?? '';
            _gradCourseCtrl.text     = data['grad_course']          ?? '';
            _gradYearGradCtrl.text   = data['grad_year_grad']       ?? '';
            _gradLevelCtrl.text      = data['grad_level']           ?? '';
            _gradYearLastCtrl.text   = data['grad_year_last']       ?? '';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Could not load educational background."),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _saveToDatabase() async {
    setState(() => _isLoading = true);
    try {
      final seekerId = widget.user?['seeker_id'];
      if (seekerId == null) throw Exception("No logged-in user found.");
      final body = jsonEncode({
        "currently_in_school": _currentlyInSchool,
        "secondary_type":      _secondaryType,
        "elem_school":         _elemSchoolCtrl.text.trim(),
        "elem_year_grad":      _elemYearGradCtrl.text.trim(),
        "elem_level":          _elemLevelCtrl.text.trim(),
        "elem_year_last":      _elemYearLastCtrl.text.trim(),
        "sec_school":          _secSchoolCtrl.text.trim(),
        "sec_course":          _secCourseCtrl.text.trim(),
        "sec_year_grad":       _secYearGradCtrl.text.trim(),
        "sec_level":           _secLevelCtrl.text.trim(),
        "sec_year_last":       _secYearLastCtrl.text.trim(),
        "tert_school":         _tertSchoolCtrl.text.trim(),
        "tert_course":         _tertCourseCtrl.text.trim(),
        "tert_year_grad":      _tertYearGradCtrl.text.trim(),
        "tert_level":          _tertLevelCtrl.text.trim(),
        "tert_year_last":      _tertYearLastCtrl.text.trim(),
        "grad_school":         _gradSchoolCtrl.text.trim(),
        "grad_course":         _gradCourseCtrl.text.trim(),
        "grad_year_grad":      _gradYearGradCtrl.text.trim(),
        "grad_level":          _gradLevelCtrl.text.trim(),
        "grad_year_last":      _gradYearLastCtrl.text.trim(),
      });
      final url = Uri.parse('$_baseUrl/api/seekers/$seekerId/educational-background');
      final response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Educational background saved!"),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        throw Exception("Server error ${response.statusCode}");
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

  // ── Reusable UI helpers ────────────────────────────────────────────

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: _labelColor, letterSpacing: 0.2)),
  );

  Widget _fieldHint(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(text,
      style: const TextStyle(fontSize: 11, color: _hintColor,
          fontStyle: FontStyle.italic)),
  );

  InputDecoration _inputDeco(String placeholder) => InputDecoration(
    hintText: placeholder,
    hintStyle: const TextStyle(color: _hintColor, fontSize: 13),
    filled: true,
    fillColor: _fieldBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
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
          border: Border.all(color: selected ? _primary : const Color(0xFFD1D5DB), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 16, color: selected ? Colors.white : _hintColor),
            const SizedBox(width: 6),
            Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _labelColor)),
          ],
        ),
      ),
    );
  }

  // N/A placeholder for non-applicable fields
  Widget _naBox(String reason) => Container(
    height: 46,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD1D5DB)),
    ),
    alignment: Alignment.center,
    child: Text(reason,
      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280),
          fontStyle: FontStyle.italic)),
  );

    // Divider with label (used inside cards to separate sections)
    Widget _sectionDivider(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280), letterSpacing: 0.5)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ]),
    );

  // ── Education level card ───────────────────────────────────────────
  Widget _educCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    Widget? extras,                       // e.g. K12 toggle for Secondary
    required TextEditingController schoolCtrl,
    bool naForCourse = false,
    Widget? courseOverride,               // custom course field
    TextEditingController? courseCtrl,
    required TextEditingController yearGradCtrl,
    required TextEditingController levelReachedCtrl,
    required TextEditingController yearLastCtrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _primary, size: 16),
              ),
              const SizedBox(width: 12),
              Text(title,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ),

          // ── Card body ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Optional extras (K12 toggle, etc.)
                if (extras != null) ...[extras, const SizedBox(height: 16)],

                // School name
                _fieldLabel('Name of School'),
                _fieldHint('Write the complete name — no abbreviations or acronyms'),
                TextFormField(
                  controller: schoolCtrl,
                  decoration: _inputDeco('e.g. Naga City Central School'),
                ),
                const SizedBox(height: 14),

                // Course / strand
                _fieldLabel('Course / Strand / Program'),
                if (!naForCourse)
                  _fieldHint('Write in full — no abbreviations or acronyms'),
                if (naForCourse)
                  _naBox('N/A — not applicable for Elementary')
                else
                  courseOverride ??
                    TextFormField(
                      controller: courseCtrl,
                      decoration: _inputDeco(
                        'e.g. Bachelor of Science in Information Technology'),
                    ),
                const SizedBox(height: 14),

                // Year graduated
                _fieldLabel('Year Graduated'),
                _fieldHint('Leave blank if you did not graduate from this level'),
                TextFormField(
                  controller: yearGradCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco('e.g. 2018'),
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
                          style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Highest Level Reached'),
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
                        _fieldLabel('Year Last Attended'),
                        TextFormField(
                          controller: yearLastCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('e.g. 2016'),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Secondary K12/Non-K12 extras widget ──────────────────────────
  Widget _secondaryExtras() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel('What type of Secondary education did you attend?'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 10,
        children: [
          _radioPill(label: 'Non-K12 (old curriculum)',
            value: 'Non-K12', groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!)),
          _radioPill(label: 'K12 (SHS strand)',
            value: 'K12', groupValue: _secondaryType,
            onChanged: (v) => setState(() => _secondaryType = v!)),
        ],
      ),
    ],
  );

  // ── BUILD ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Currently in school card ─────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(Icons.school, color: _primary, size: 18),
                    SizedBox(width: 8),
                    Text('Are you currently enrolled in school?',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 14, color: _primary)),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, children: [
                    _radioPill(label: 'Yes, currently enrolled',
                      value: 'Yes', groupValue: _currentlyInSchool,
                      onChanged: (v) => setState(() => _currentlyInSchool = v!)),
                    _radioPill(label: 'No',
                      value: 'No', groupValue: _currentlyInSchool,
                      onChanged: (v) => setState(() => _currentlyInSchool = v!)),
                  ]),
                ],
              ),
            ),

            // ── Instructions banner ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lightbulb_outline, color: Color(0xFFD97706), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fill in the sections that apply to you. You may leave a section '
                      'blank if it does not apply. Always write the complete name of the '
                      'school and course — do not use acronyms or abbreviations.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.6),
                    ),
                  ),
                ],
              ),
            ),

            // ── Education level cards ────────────────────────────
            _educCard(
              title: 'Elementary',
              icon: Icons.child_care_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              schoolCtrl: _elemSchoolCtrl,
              naForCourse: true,
              yearGradCtrl: _elemYearGradCtrl,
              levelReachedCtrl: _elemLevelCtrl,
              yearLastCtrl: _elemYearLastCtrl,
            ),

            _educCard(
              title: 'Secondary (High School)',
              icon: Icons.menu_book_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              extras: _secondaryExtras(),
              schoolCtrl: _secSchoolCtrl,
              courseOverride: TextFormField(
                controller: _secCourseCtrl,
                decoration: _inputDeco(
                  _secondaryType == 'K12'
                    ? 'e.g. Science, Technology, Engineering & Mathematics (STEM)'
                    : 'e.g. General Secondary Education'),
              ),
              yearGradCtrl: _secYearGradCtrl,
              levelReachedCtrl: _secLevelCtrl,
              yearLastCtrl: _secYearLastCtrl,
            ),

            _educCard(
              title: 'Tertiary (College)',
              icon: Icons.account_balance_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              schoolCtrl: _tertSchoolCtrl,
              courseCtrl: _tertCourseCtrl,
              yearGradCtrl: _tertYearGradCtrl,
              levelReachedCtrl: _tertLevelCtrl,
              yearLastCtrl: _tertYearLastCtrl,
            ),

            _educCard(
              title: 'Graduate Studies / Post-graduate',
              icon: Icons.workspace_premium_outlined,
              iconBgColor: const Color(0xFFDCFCE7),
              schoolCtrl: _gradSchoolCtrl,
              courseCtrl: _gradCourseCtrl,
              yearGradCtrl: _gradYearGradCtrl,
              levelReachedCtrl: _gradLevelCtrl,
              yearLastCtrl: _gradYearLastCtrl,
            ),

            // ── Action buttons ───────────────────────────────────
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _accent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                  child: const Text('Cancel',
                    style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    elevation: 0,
                  ),
                  icon: _isLoading
                    ? const SizedBox(height: 16, width: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_isLoading ? 'Saving...' : 'Save Changes',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}