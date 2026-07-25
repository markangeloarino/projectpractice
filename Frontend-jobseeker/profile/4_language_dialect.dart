import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LanguageDialect extends StatefulWidget {
  final Map<String, dynamic>? user;
  const LanguageDialect({super.key, required this.user});
  @override
  State<LanguageDialect> createState() => _LanguageDialectState();
}

class _LanguageDialectState extends State<LanguageDialect> {
  // --- LANGUAGE/DIALECT PROFICIENCY STATE ---
  bool _engRead = false, _engWrite = false, _engSpeak = false, _engUnderstand = false;
  bool _filRead = false, _filWrite = false, _filSpeak = false, _filUnderstand = false;
  bool _manRead = false, _manWrite = false, _manSpeak = false, _manUnderstand = false;
  bool _othRead = false, _othWrite = false, _othSpeak = false, _othUnderstand = false;
  final TextEditingController _othersLangCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadLanguageData();
  }

  Future<void> _loadLanguageData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/language-proficiency');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _engRead = data['eng_read'] == 1;
            _engWrite = data['eng_write'] == 1;
            _engSpeak = data['eng_speak'] == 1;
            _engUnderstand = data['eng_understand'] == 1;

            _filRead = data['fil_read'] == 1;
            _filWrite = data['fil_write'] == 1;
            _filSpeak = data['fil_speak'] == 1;
            _filUnderstand = data['fil_understand'] == 1;

            _manRead = data['man_read'] == 1;
            _manWrite = data['man_write'] == 1;
            _manSpeak = data['man_speak'] == 1;
            _manUnderstand = data['man_understand'] == 1;

            _othersLangCtrl.text = data['other_language'] ?? '';
            _othRead = data['oth_read'] == 1;
            _othWrite = data['oth_write'] == 1;
            _othSpeak = data['oth_speak'] == 1;
            _othUnderstand = data['oth_understand'] == 1;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load language proficiencies."), backgroundColor: Colors.red),
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
        "eng_read": _engRead ? 1 : 0, "eng_write": _engWrite ? 1 : 0, "eng_speak": _engSpeak ? 1 : 0, "eng_understand": _engUnderstand ? 1 : 0,
        "fil_read": _filRead ? 1 : 0, "fil_write": _filWrite ? 1 : 0, "fil_speak": _filSpeak ? 1 : 0, "fil_understand": _filUnderstand ? 1 : 0,
        "man_read": _manRead ? 1 : 0, "man_write": _manWrite ? 1 : 0, "man_speak": _manSpeak ? 1 : 0, "man_understand": _manUnderstand ? 1 : 0,
        "other_language": _othersLangCtrl.text.trim(),
        "oth_read": _othRead ? 1 : 0, "oth_write": _othWrite ? 1 : 0, "oth_speak": _othSpeak ? 1 : 0, "oth_understand": _othUnderstand ? 1 : 0,
      };

      final String baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/language-proficiency');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Language Proficiencies saved!"), backgroundColor: Colors.green));
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
    _othersLangCtrl.dispose();
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
        _buildLabel("LANGUAGE/DIALECT PROFICIENCY (check if applicable)"),
        const Divider(color: Colors.black54, thickness: 1.5),

        // --- TABLE HEADER ---
        Row(
          children: [
            Expanded(flex: 3, child: Text("LANGUAGE/DIALECT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
            Expanded(flex: 1, child: Center(child: Text("READ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)))),
            Expanded(flex: 1, child: Center(child: Text("WRITE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)))),
            Expanded(flex: 1, child: Center(child: Text("SPEAK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)))),
            Expanded(flex: 1, child: Center(child: Text("UNDERSTAND", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)))),
          ],
        ),
        const Divider(color: Colors.black54),

        // --- ROWS ---
        _buildLangRow("English", _engRead, (v) => setState(() => _engRead = v!), _engWrite, (v) => setState(() => _engWrite = v!), _engSpeak, (v) => setState(() => _engSpeak = v!), _engUnderstand, (v) => setState(() => _engUnderstand = v!)),
        const Divider(),

        _buildLangRow("Filipino", _filRead, (v) => setState(() => _filRead = v!), _filWrite, (v) => setState(() => _filWrite = v!), _filSpeak, (v) => setState(() => _filSpeak = v!), _filUnderstand, (v) => setState(() => _filUnderstand = v!)),
        const Divider(),

        _buildLangRow("Mandarin", _manRead, (v) => setState(() => _manRead = v!), _manWrite, (v) => setState(() => _manWrite = v!), _manSpeak, (v) => setState(() => _manSpeak = v!), _manUnderstand, (v) => setState(() => _manUnderstand = v!)),
        const Divider(),

        // --- OTHERS ROW (Special Case with TextField) ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    const Text("Others: ", style: TextStyle(fontWeight: FontWeight.w500)),
                    Expanded(child: Padding(padding: const EdgeInsets.only(right: 15.0), child: _buildGreyTextFieldController(_othersLangCtrl))),
                  ],
                ),
              ),
              Expanded(flex: 1, child: Center(child: Checkbox(value: _othRead, onChanged: (v) => setState(() => _othRead = v!), activeColor: const Color(0xFF1D3A8A)))),
              Expanded(flex: 1, child: Center(child: Checkbox(value: _othWrite, onChanged: (v) => setState(() => _othWrite = v!), activeColor: const Color(0xFF1D3A8A)))),
              Expanded(flex: 1, child: Center(child: Checkbox(value: _othSpeak, onChanged: (v) => setState(() => _othSpeak = v!), activeColor: const Color(0xFF1D3A8A)))),
              Expanded(flex: 1, child: Center(child: Checkbox(value: _othUnderstand, onChanged: (v) => setState(() => _othUnderstand = v!), activeColor: const Color(0xFF1D3A8A)))),
            ],
          ),
        ),
        const Divider(),

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("CANCEL", style: TextStyle(color: Color(0xFF3B82F6))),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: _isLoading ? null : _saveToDatabase,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1D3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  // Helper for generating the Language/Dialect rows
  Widget _buildLangRow(
    String lang, bool read, Function(bool?) onRead, bool write, Function(bool?) onWrite,
    bool speak, Function(bool?) onSpeak, bool understand, Function(bool?) onUnderstand,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(lang, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: Center(child: Checkbox(value: read, onChanged: onRead, activeColor: const Color(0xFF1D3A8A)))),
          Expanded(flex: 1, child: Center(child: Checkbox(value: write, onChanged: onWrite, activeColor: const Color(0xFF1D3A8A)))),
          Expanded(flex: 1, child: Center(child: Checkbox(value: speak, onChanged: onSpeak, activeColor: const Color(0xFF1D3A8A)))),
          Expanded(flex: 1, child: Center(child: Checkbox(value: understand, onChanged: onUnderstand, activeColor: const Color(0xFF1D3A8A)))),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87, letterSpacing: 0.5)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          isDense: true,
          suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        ),
      ),
    );
  }
}