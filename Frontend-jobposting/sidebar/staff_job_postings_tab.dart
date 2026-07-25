import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';

class StaffJobPostingsTab extends StatefulWidget {
  const StaffJobPostingsTab({super.key});

  @override
  State<StaffJobPostingsTab> createState() => _StaffJobPostingsTabState();
}

class _StaffJobPostingsTabState extends State<StaffJobPostingsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final _vacancyFormKey = GlobalKey<FormState>();
  final TextEditingController _jobTitleCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();
  final TextEditingController _vacancyCountCtrl = TextEditingController();
  final TextEditingController _industryCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _deadlineCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _qualCtrl = TextEditingController();
  final TextEditingController _careerLinkCtrl = TextEditingController();
  String _jobLocationType = 'Local';

  final Color sidebarBlue = const Color(0xFF23367A);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color primaryAccent = const Color(0xFF1D4ED8);

  @override
  void dispose() {
    _searchController.dispose();
    _jobTitleCtrl.dispose();
    _experienceCtrl.dispose();
    _salaryCtrl.dispose();
    _vacancyCountCtrl.dispose();
    _industryCtrl.dispose();
    _locationCtrl.dispose();
    _deadlineCtrl.dispose();
    _descCtrl.dispose();
    _qualCtrl.dispose();
    _careerLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VacancyProvider>();
    final filteredJobs = provider.activeJobs.where((job) {
      final title = job['job_title']?.toString().toLowerCase() ?? '';
      final employer = job['employer_name']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) ||
          employer.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Job Postings",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Manage active job vacancies and applicants",
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showJobDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  "Post New Job",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sidebarBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search by job title or employer...",
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 25),
          // Main Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "JOB TITLE",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "EMPLOYER",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "TYPE",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ), // NEW
                        Expanded(
                          flex: 2,
                          child: Text(
                            "LOCATION",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "POSTED",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "APPLICANTS",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ), // NEW
                        Expanded(
                          flex: 1,
                          child: Text(
                            "STATUS",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "ACTIONS",
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Body
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredJobs.isEmpty
                        ? Center(
                            child: Text(
                              "No job postings found.",
                              style: TextStyle(color: textMuted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredJobs.length,
                            separatorBuilder: (context, index) =>
                                Divider(color: Colors.grey.shade200, height: 1),
                            itemBuilder: (context, index) {
                              final job = filteredJobs[index];
                              bool isClosed = job['status'] == 'Closed';

                              // Fetch applicant count from database mapping
                              int applicantCount = job['applicant_count'] ?? 0;

                              String postedDate = 'N/A';
                              if (job['date_posted'] != null) {
                                try {
                                  postedDate = DateFormat('MMM dd, yyyy')
                                      .format(
                                        DateTime.parse(
                                          job['date_posted'].toString(),
                                        ).toLocal(),
                                      );
                                } catch (_) {}
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 15,
                                ),
                                child: Row(
                                  children: [
                                    // Title
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        job['job_title'] ?? 'Unknown',
                                        style: TextStyle(
                                          color: textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // Employer
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        job['employer_name'] ?? 'Unknown',
                                        style: TextStyle(
                                          color: textDark,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // NEW: Employment Type Badge
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            job['employment_type'] ?? 'N/A',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Location
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        job['location'] ?? 'N/A',
                                        style: TextStyle(
                                          color: textDark,
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    // Date
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        postedDate,
                                        style: TextStyle(
                                          color: textDark,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    // NEW: Applicants Count
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "$applicantCount",
                                        style: TextStyle(
                                          color: textDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Status
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isClosed
                                                ? Colors.grey.shade200
                                                : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            job['status']?.toUpperCase() ??
                                                'ACTIVE',
                                            style: TextStyle(
                                              color: isClosed
                                                  ? Colors.grey.shade700
                                                  : Colors.green.shade800,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Actions
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          WidgetActionsEdit(
                                            onTap: () => _showJobDialog(
                                              context,
                                              existingJob: job,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          InkWell(
                                            onTap: () => _confirmDelete(
                                              context,
                                              job['vacancy_id'],
                                              provider,
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red.shade400,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 void _showJobDialog(BuildContext context, {Map<String, dynamic>? existingJob}) {
    bool isEditing = existingJob != null;
    final providers = context.read<VacancyProvider>();
    
    List<String> companyNames = providers.employers.map<String>((e) => e['company_name'].toString()).toSet().toList();
    
    // Default to null for new jobs so the hint text will actually display
    String? selectedEmployer = (isEditing && companyNames.contains(existingJob['employer_name'])) 
        ? existingJob['employer_name'] 
        : null; 

    _jobTitleCtrl.text = isEditing ? existingJob['job_title'] ?? '' : '';
    String selectedEmpType = isEditing ? existingJob['employment_type'] ?? 'Full-time' : 'Full-time';
    
    String selectedJobScope = isEditing ? existingJob['job_location_type'] ?? 'Local' : 'Local';
    
    _locationCtrl.text = isEditing ? existingJob['location'] ?? '' : '';
    _vacancyCountCtrl.text = isEditing ? existingJob['vacancies_count']?.toString() ?? '1' : '1';
    _salaryCtrl.text = isEditing ? existingJob['salary'] ?? '' : '';
    
    _experienceCtrl.text = isEditing ? existingJob['years_experience']?.toString() ?? '0' : '0';
    _careerLinkCtrl.text = isEditing ? existingJob['employer_career_link'] ?? '' : '';
    
    _deadlineCtrl.text = (isEditing && existingJob['application_deadline'] != null) ? existingJob['application_deadline'].toString().substring(0, 10) : '';
    _descCtrl.text = isEditing ? existingJob['job_description'] ?? '' : '';
    _qualCtrl.text = isEditing ? existingJob['qualifications'] ?? '' : '';
    
    String status = isEditing ? existingJob['status'] ?? 'Active' : 'Active';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: cardWhite,
          child: Container(
            width: 700, padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Form(
                key: _vacancyFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEditing ? "Edit Job Vacancy" : "New Job Vacancy", style: TextStyle(color: textDark, fontSize: 22)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // ROW 1: Title and Company
                    Row(
                      children: [
                        Expanded(child: _buildFormTextField(_jobTitleCtrl, "Job Title", true)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildLabeledField(
                            "Company / Employer", 
                            true, 
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedEmployer, 
                              dropdownColor: cardWhite,
                              hint: const Text(
                                "Select Employer", 
                                style: TextStyle(color: Colors.grey),
                              ),
                              decoration: _dropdownDecoration(),
                              items: companyNames.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) => setStateDialog(() => selectedEmployer = v),
                              validator: (value) => value == null || value.isEmpty ? "Required" : null,
                            )
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // ROW 2: Employment Type and Status
                    Row(
                      children: [
                        Expanded(child: _buildLabeledField("Employment Type", true, DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedEmpType, dropdownColor: cardWhite, decoration: _dropdownDecoration(),
                          items: ['Full-time', 'Part-time', 'Contract', 'Temporary', 'Internship'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setStateDialog(() => selectedEmpType = v!),
                        ))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildLabeledField("Job Status", true, DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: status, dropdownColor: cardWhite, decoration: _dropdownDecoration(),
                          items: ['Active', 'Closed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setStateDialog(() => status = v!),
                        ))),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // ROW 3: Job Scope and Employer Career Website (Swapped!)
                    Row(
                      children: [
                        Expanded(child: _buildLabeledField("Job Scope", false, DropdownButtonFormField<String>(
                          isExpanded: true, 
                          value: selectedJobScope, dropdownColor: cardWhite, decoration: _dropdownDecoration(),
                          items: ['Local', 'Overseas'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setStateDialog(() => selectedJobScope = v!),
                        ))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFormTextField(_careerLinkCtrl, "Employer Career Website (Optional)", false, suffixIcon: const Icon(Icons.link, color: Colors.grey))),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // ROW 4: Vacancies and Salary
                    Row(
                      children: [
                        Expanded(child: _buildFormTextField(_vacancyCountCtrl, "Number of Vacancies", false, isNumber: true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFormTextField(_salaryCtrl, "Salary", false)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // ROW 5: Experience and Deadline
                    Row(
                      children: [
                        Expanded(child: _buildFormTextField(_experienceCtrl, "Years of Experience", false, isNumber: true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFormTextField(_deadlineCtrl, "Application Deadline (Optional)", false, isReadOnly: true, onTap: () async {
                          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2100));
                          if (picked != null) setStateDialog(() => _deadlineCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
                        })),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // ROW 6: Location (Now takes the full width!)
                    _buildFormTextField(_locationCtrl, "Location", true),
                    const SizedBox(height: 15),

                    _buildFormTextField(_descCtrl, "Job Description / Job Responsibilities", false, maxLines: 6),
                    const SizedBox(height: 15),
                    _buildFormTextField(_qualCtrl, "Qualifications / Requirements", true, maxLines: 6),
                    const SizedBox(height: 35),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D3A8A), padding: const EdgeInsets.symmetric(vertical: 20)),
                            onPressed: () async {
                              if (_vacancyFormKey.currentState!.validate()) {
                                Map<String, dynamic> data = {
                                  "job_title": _jobTitleCtrl.text.trim(),
                                  "employer_name": selectedEmployer ?? '',
                                  "employment_type": selectedEmpType,
                                  "location": _locationCtrl.text.trim(),
                                  "job_location_type": selectedJobScope,
                                  "salary": _salaryCtrl.text.trim(),
                                  "vacancies_count": int.tryParse(_vacancyCountCtrl.text) ?? 1,
                                  "years_experience": int.tryParse(_experienceCtrl.text) ?? 0,
                                  "employer_career_link": _careerLinkCtrl.text.isEmpty ? null : _careerLinkCtrl.text.trim(),
                                  "application_deadline": _deadlineCtrl.text.isEmpty ? null : _deadlineCtrl.text,
                                  "job_description": _descCtrl.text.trim(),
                                  "qualifications": _qualCtrl.text.trim(),
                                  "status": status,
                                };
                                bool success = isEditing 
                                  ? await context.read<VacancyProvider>().updateVacancy(existingJob['vacancy_id'], data)
                                  : await context.read<VacancyProvider>().encodeVacancy(data);
                                if (mounted && success) {
                                  Navigator.pop(context);
                                  context.read<VacancyProvider>().fetchVacancies();
                                }
                              }
                            },
                            child: Text(isEditing ? "Update Job" : "Post Job", style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, VacancyProvider p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
          "Are you sure you want to permanently delete this job posting?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await p.deleteVacancy(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField(
    TextEditingController controller,
    String label,
    bool isRequired, {
    int maxLines = 1,
    bool isNumber = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon, // <-- Added this parameter
  }) {
    return _buildLabeledField(
      label,
      isRequired,
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: isReadOnly,
        onTap: onTap,
        keyboardType: isNumber
            ? TextInputType.number
            : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        decoration: InputDecoration(
          suffixIcon: suffixIcon, // <-- Applied the icon to the text field
          contentPadding: const EdgeInsets.all(15),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryAccent),
          ),
        ),
        validator: isRequired ? (v) => v!.isEmpty ? "Required" : null : null,
      ),
    );
  }

  Widget _buildLabeledField(String label, bool isRequired, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.all(15),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  );
}

class WidgetActionsEdit extends StatelessWidget {
  final VoidCallback onTap;
  const WidgetActionsEdit({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
    );
  }
}
