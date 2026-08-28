import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nagajob/Frontend-jobseeker/widget/form_style.dart';

class OtherSkills extends StatefulWidget {
  final Map<String, dynamic>? user;
  const OtherSkills({super.key, required this.user});

  @override
  State<OtherSkills> createState() => _OtherSkillsState();
}

class _OtherSkillsState extends State<OtherSkills> {
  // --- OTHER SKILLS STATE ---
  final Map<String, bool> _skills = {
    "Auto Mechanic": false,
    "Beautician": false,
    "Carpentry Work": false,
    "Computer Literate": false,
    "Domestic Chores": false,
    "Driver": false,
    "Electrician": false,
    "Embroidery": false,
    "Gardening": false,
    "Masonry": false,
    "Painter/Artist": false,
    "Painting Jobs": false,
    "Photography": false,
    "Plumbing": false,
    "Sewing Dresses": false,
    "Stenography": false,
    "Tailoring": false,
  };
  final TextEditingController _othersSkillCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  // ==========================================
  // INITIALIZE STATE & FETCH LATEST DATA
  // ==========================================
  @override
  void initState() {
    super.initState();
    _loadSkillsData();
  }

  Future<void> _loadSkillsData() async {
    final seekerId = widget.user?['seeker_id'];
    if (seekerId == null) return;

    try {
      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/other-skills');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            _othersSkillCtrl.text = data['others_specify'] ?? '';

            // Read the saved string (e.g. "Auto Mechanic, Driver, Plumber")
            final String savedSkills = data['skills_list'] ?? '';
            final List<String> savedSkillsList = savedSkills
                .split(', ')
                .map((e) => e.trim())
                .toList();

            // Set the checkboxes to true if they match the saved string
            for (String skill in _skills.keys.toList()) {
              _skills[skill] = savedSkillsList.contains(skill);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not load other skills."),
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

      // Package all true checkboxes into a single comma-separated string
      final List<String> selectedSkills = _skills.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      final String skillsListString = selectedSkills.join(', ');

      final Map<String, dynamic> formData = {
        "skills_list": skillsListString,
        "others_specify": _othersSkillCtrl.text.trim(),
      };

      final String baseUrl = kIsWeb
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';
      final url = Uri.parse('$baseUrl/api/seekers/$seekerId/other-skills');

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
              content: Text("Other Skills saved successfully!"),
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
    _othersSkillCtrl.dispose();
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
        // Grid layout for skills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _skills.keys.map((skill) {
            return SizedBox(
              width: 250, // Ensures 3-column layout on wide screens
              child: BuildCheckbox(
                title: skill,
                value: _skills[skill]!,
                onChanged: (v) => setState(() => _skills[skill] = v!),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          child: GreyTextField(controller: _othersSkillCtrl, hint: "Others:"),
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
}
