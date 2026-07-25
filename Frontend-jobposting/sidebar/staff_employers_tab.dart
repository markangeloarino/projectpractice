import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';

class StaffEmployersTab extends StatefulWidget {
  const StaffEmployersTab({super.key});

  @override
  State<StaffEmployersTab> createState() => _StaffEmployersTabState();
}

class _StaffEmployersTabState extends State<StaffEmployersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final _employerFormKey = GlobalKey<FormState>();
  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();
  final TextEditingController _contactPersonCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _logoUrlCtrl = TextEditingController();
  final TextEditingController _companyDescCtrl = TextEditingController();

  final Color sidebarBlue = const Color(0xFF23367A);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color primaryAccent = const Color(0xFF1D4ED8);

  @override
  void dispose() {
    _searchController.dispose();
    _companyNameCtrl.dispose();
    _websiteCtrl.dispose();
    _contactPersonCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _logoUrlCtrl.dispose();
    _companyDescCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VacancyProvider>();
    final employerList = provider.employers.where((emp) {
      final name = emp['company_name']?.toString().toLowerCase() ?? '';
      final contact = emp['contact_person']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || contact.contains(query);
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
                  Text("Employers", style: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Manage registered employers and companies", style: TextStyle(color: textMuted, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showEmployerDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text("Add Employer", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: sidebarBlue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search by company name, contact person, or industry...",
                      hintStyle: TextStyle(color: textMuted, fontSize: 14),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Main Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text("COMPANY", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 2, child: Text("CONTACT PERSON", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 2, child: Text("INDUSTRY", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 1, child: Text("ACTIVE JOBS", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))), // NEW
                        Expanded(flex: 1, child: Text("REGISTERED", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 1, child: Text("ACTIONS", style: TextStyle(color: textMuted, fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                    ),
                  ),
                  // Table Body
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : employerList.isEmpty
                            ? Center(child: Text("No employers found.", style: TextStyle(color: textMuted)))
                            : ListView.separated(
                                itemCount: employerList.length,
                                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                                itemBuilder: (context, index) {
                                  final emp = employerList[index];
                                  
                                  // NEW: Dynamically count the active jobs for this specific employer
                                  int activeJobsCount = provider.activeJobs.where((job) => 
                                      job['employer_name'] == emp['company_name'] && 
                                      job['status'] != 'Closed'
                                  ).length;

                                  String regDate = 'N/A';
                                  if (emp['registered_at'] != null) {
                                    try {
                                      regDate = DateFormat('MMM dd, yyyy').format(DateTime.parse(emp['registered_at'].toString()).toLocal());
                                    } catch (_) {}
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                    child: Row(
                                      children: [
                                        // Company Details
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40, height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey.shade200),
                                                  image: (emp['logo_url'] != null && emp['logo_url'].toString().isNotEmpty)
                                                      ? DecorationImage(image: NetworkImage(emp['logo_url']), fit: BoxFit.cover)
                                                      : null,
                                                ),
                                                child: (emp['logo_url'] == null || emp['logo_url'].toString().isEmpty)
                                                    ? Icon(Icons.business, color: primaryAccent, size: 20)
                                                    : null,
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(emp['company_name'] ?? 'Unknown', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                                    Text(emp['address'] ?? 'Naga City', style: TextStyle(color: textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        // Contact Person
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(emp['contact_person'] ?? 'N/A', style: TextStyle(color: textDark, fontSize: 14)),
                                              Text(emp['email'] ?? 'N/A', style: TextStyle(color: textMuted, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        // Industry Badge
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)),
                                              child: Text(emp['industry'] ?? 'N/A', style: TextStyle(color: Colors.purple.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        // NEW: Active Jobs Count
                                        Expanded(
                                          flex: 1, 
                                          child: Text("$activeJobsCount", style: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.bold))
                                        ),
                                        // Date Registered
                                        Expanded(flex: 1, child: Text(regDate, style: TextStyle(color: textDark, fontSize: 13))),
                                        // Actions
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            children: [
                                              InkWell(onTap: () => _showEmployerDialog(context, existingEmployer: emp), child: Icon(Icons.edit_outlined, color: textMuted, size: 18)),
                                              const SizedBox(width: 15),
                                              InkWell(onTap: () => _confirmDeleteEmployer(context, emp['employer_id'], provider), child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18)),
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
          )
        ],
      ),
    );
  }

  void _showEmployerDialog(BuildContext context, {Map<String, dynamic>? existingEmployer}) {
    bool isEditing = existingEmployer != null;
    _companyNameCtrl.text = isEditing ? existingEmployer['company_name'] ?? '' : '';
    _websiteCtrl.text = isEditing ? existingEmployer['website'] ?? '' : '';
    _contactPersonCtrl.text = isEditing ? existingEmployer['contact_person'] ?? '' : '';
    _emailCtrl.text = isEditing ? existingEmployer['email'] ?? '' : '';
    _phoneCtrl.text = isEditing ? existingEmployer['phone'] ?? '' : '';
    _addressCtrl.text = isEditing ? existingEmployer['address'] ?? '' : '';
    _logoUrlCtrl.text = isEditing ? existingEmployer['logo_url'] ?? '' : '';
    _companyDescCtrl.text = isEditing ? existingEmployer['company_description'] ?? '' : '';
    String selectedIndustry = isEditing ? existingEmployer['industry'] ?? 'Healthcare' : 'Healthcare';

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
                key: _employerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEditing ? "Edit Employer Details" : "Add  Employer", style: TextStyle(color: textDark, fontSize: 22)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildFormTextField(_logoUrlCtrl, "Company Logo (Image URL)", false, hint: "https://example.com/logo.png"),
                    const SizedBox(height: 15),
                    _buildFormTextField(_companyNameCtrl, "Company Name", true),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledField("Industry", true, DropdownButtonFormField<String>(
                            value: selectedIndustry, dropdownColor: cardWhite,
                            decoration: _dropdownDecoration(),
                            items: ['Healthcare', 'Information Technology', 'Manufacturing', 'Retail', 'BPO/Call Center', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setStateDialog(() => selectedIndustry = v!),
                          )),
                        ),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFormTextField(_contactPersonCtrl, "Contact Person", true)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildFormTextField(_emailCtrl, "Email", true)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFormTextField(_phoneCtrl, "Phone", true, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildFormTextField(_addressCtrl, "Address", true, maxLines: 2),
                    const SizedBox(height: 15),
                    _buildFormTextField(_companyDescCtrl, "Company Description / Overview", false, maxLines: 4),
                    const SizedBox(height: 35),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D3A8A), padding: const EdgeInsets.symmetric(vertical: 20)),
                            onPressed: () => _submitEmployer(context, selectedIndustry, "Active", isEditing ? existingEmployer['employer_id'] : null),
                            child: Text(isEditing ? "Update Employer" : "Add Employer", style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        )
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

  Future<void> _submitEmployer(BuildContext context, String industry, String status, int? editId) async {
    if (_employerFormKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "company_name": _companyNameCtrl.text.trim(),
        "industry": industry,
        "website": _websiteCtrl.text.trim(),
        "contact_person": _contactPersonCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "phone": _phoneCtrl.text.trim(),
        "address": _addressCtrl.text.trim(),
        "logo_url": _logoUrlCtrl.text.trim(),
        "status": status,
        "company_description": _companyDescCtrl.text.trim(),
      };
      bool success = editId != null 
        ? await context.read<VacancyProvider>().updateEmployer(editId, data)
        : await context.read<VacancyProvider>().registerEmployer(data.map((k, v) => MapEntry(k, v.toString())));
      if (mounted && success) {
        Navigator.pop(context);
        context.read<VacancyProvider>().fetchEmployers();
      }
    }
  }

  void _confirmDeleteEmployer(BuildContext context, int employerId, VacancyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Employer"),
        content: const Text("Are you sure you want to remove this employer?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteEmployer(employerId);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildFormTextField(TextEditingController controller, String label, bool isRequired, {int maxLines = 1, bool isNumber = false, String? hint}) {
    return _buildLabeledField(label, isRequired, TextFormField(
      controller: controller, maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(15), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryAccent))),
      validator: isRequired ? (v) => v!.isEmpty ? "Required" : null : null,
    ));
  }

  Widget _buildLabeledField(String label, bool isRequired, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 8), child]);
  }

  InputDecoration _dropdownDecoration() => InputDecoration(contentPadding: const EdgeInsets.all(15), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)));
}