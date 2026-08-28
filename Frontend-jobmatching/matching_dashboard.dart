import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
 
import '../Frontend-jobposting/post_vacancy_provider.dart';
import '../auth_provider.dart';
import '../screen_staff_login.dart'; 

class ScreenJobMatcherDashboard extends StatefulWidget {
  const ScreenJobMatcherDashboard({super.key});

  @override
  State<ScreenJobMatcherDashboard> createState() =>
      _ScreenJobMatcherDashboardState();
}

class _ScreenJobMatcherDashboardState extends State<ScreenJobMatcherDashboard> {
  int _selectedMenu = 4; // 4 = Job Matching
  int _selectedJobIndex = 0; // 0 = All Jobs, 1+ = Specific Job
  String _searchQuery = "";

  // --- Theme Colors ---
  final Color sidebarBlue = const Color(0xFF23367A);
  final Color sidebarActive = const Color(0xFF334A99);
  final Color mainBg = const Color(0xFFF8FAFC);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color primaryAccent = const Color(0xFF1D4ED8);
  final Color successGreen = const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacancyProvider>().fetchVacancies();
      context.read<VacancyProvider>().fetchAllApplications();
    });
  }

  String _getInitials(String? text, int length) {
    if (text == null || text.trim().isEmpty) return "U";
    String trimmed = text.trim();
    if (trimmed.length < length) return trimmed.toUpperCase();
    return trimmed.substring(0, length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    final allApps = vacancyProvider.allApplications;

    return Scaffold(
      backgroundColor: mainBg,
      body: Row(
        children: [
          _buildSidebar(user),
          Expanded(
            child: Column(
              children: [
                _buildHeader(user),
                Expanded(
                  child: _selectedMenu == 1
                      ? _buildJobSeekersTable(allApps)
                      : _buildJobMatchingContent(
                          vacancyProvider.activeJobs,
                          allApps,
                          vacancyProvider,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIDEBAR & HEADER
  // ==========================================
  Widget _buildSidebar(Map<String, dynamic>? user) {
    return Container(
      width: 250,
      color: sidebarBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.account_balance,
                    color: sidebarBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PESO Naga",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Admin Portal",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _sidebarItem(0, Icons.grid_view, "Dashboard"),
                _sidebarItem(1, Icons.people_outline, "Job Seekers"),
                _sidebarItem(4, Icons.handshake_outlined, "Job Matching"),
                _sidebarItem(6, Icons.bar_chart, "Reports & Analytics"),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryAccent,
                  child: Text(
                    _getInitials(user?['name'], 2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?['name'] ?? "Job Matcher",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "PESO Officer",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: InkWell(
              onTap: () {
                context.read<AuthProvider>().currentUser = null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenStaffLogin(),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.white70, size: 20),
                  SizedBox(width: 10),
                  Text("Logout", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    bool isActive = _selectedMenu == index;
    return InkWell(
      onTap: () => setState(() => _selectedMenu = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? sidebarActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      color: cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 400,
            decoration: BoxDecoration(
              color: mainBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search job seekers, employers, programs...",
                hintStyle: TextStyle(color: textMuted),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_none, color: textDark),
              const SizedBox(width: 20),
              Icon(Icons.mail_outline, color: textDark),
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 16,
                backgroundColor: sidebarBlue,
                child: Text(
                  _getInitials(user?['name'], 2),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DASHBOARD LAYOUT & STATS
  // ==========================================
  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Job Matching & Referral",
              style: TextStyle(
                color: textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Match job seekers with suitable job openings",
              style: TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Auto-Match algorithm processing..."),
              ),
            );
          },
          icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          label: const Text(
            "Run Auto-Match",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: sidebarBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int totalApps, int hired, int pending) {
    return Row(
      children: [
        _buildStatCard("Total Applications", "$totalApps", textDark),
        const SizedBox(width: 15),
        _buildStatCard(
          "High Match (90%+)",
          "0",
          successGreen,
        ), // Placeholder for future AI metric
        const SizedBox(width: 15),
        _buildStatCard("Successfully Hired", "$hired", primaryAccent),
        const SizedBox(width: 15),
        _buildStatCard("Pending Review", "$pending", Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color countColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: textMuted, fontSize: 13)),
            const SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(
                color: countColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LEFT PANE: REAL AVAILABLE JOBS
  // ==========================================
  Widget _buildLeftPane(List<dynamic> activeJobs, List<dynamic> allApps) {
    // Filter jobs strictly based on search box above the list
    List<dynamic> filteredJobs = activeJobs.where((job) {
      final title = job['job_title']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Jobs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search jobs...",
                hintStyle: TextStyle(color: textMuted, fontSize: 14),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: textMuted, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              itemCount: filteredJobs.length + 1, // +1 for "All Jobs"
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                bool isSelected = _selectedJobIndex == index;

                if (index == 0) {
                  // ALL JOBS BUTTON
                  return InkWell(
                    onTap: () => setState(() => _selectedJobIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isSelected ? sidebarBlue : cardWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? sidebarBlue
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.list,
                                color: isSelected ? Colors.white : textDark,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "All Jobs",
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${allApps.length} total applications",
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // DYNAMIC JOB BUTTONS
                final job = filteredJobs[index - 1];
                int matchCount = allApps
                    .where((a) => a['job_title'] == job['job_title'])
                    .length;
                int positionCount = job['vacancies_count'] ?? 1;

                return InkWell(
                  onTap: () => setState(() => _selectedJobIndex = index),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isSelected ? sidebarBlue : cardWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? sidebarBlue : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: isSelected ? Colors.white : textDark,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                job['job_title'] ?? 'Unknown Job',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job['employer_name'] ?? 'Unknown Company',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$matchCount applications • $positionCount positions",
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RIGHT PANE: CANDIDATE MATCHES (REAL DATA)
  // ==========================================
  Widget _buildRightPane(
    List<dynamic> activeJobs,
    List<dynamic> allApps,
    VacancyProvider provider,
  ) {
    List<dynamic> displayCandidates = [];
    String jobTitleHeader = "All Jobs";

    // Filtering based on selection
    if (_selectedJobIndex == 0 || activeJobs.isEmpty) {
      displayCandidates = allApps;
    } else {
      // Adjust index because 0 is "All Jobs"
      if ((_selectedJobIndex - 1) < activeJobs.length) {
        final selectedJob = activeJobs[_selectedJobIndex - 1];
        jobTitleHeader = selectedJob['job_title'] ?? "Unknown Job";
        displayCandidates = allApps
            .where((a) => a['job_title'] == selectedJob['job_title'])
            .toList();
      } else {
        // Fallback safety
        _selectedJobIndex = 0;
        displayCandidates = allApps;
      }
    }

    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jobTitleHeader == "All Jobs"
                    ? "All Matches"
                    : "Matches for $jobTitleHeader",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${displayCandidates.length} candidates",
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: displayCandidates.isEmpty
                ? Center(
                    child: Text(
                      "No candidates applied for this position yet.",
                      style: TextStyle(color: textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: displayCandidates.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final candidate = displayCandidates[index];
                      return _buildCandidateCard(candidate, provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

 Widget _buildCandidateCard(
    Map<String, dynamic> candidate,
    VacancyProvider provider,
  ) {
    String fullName =
        "${candidate['first_name'] ?? ''} ${candidate['last_name'] ?? ''}"
            .trim();
    if (fullName.isEmpty) fullName = "Unknown Applicant";

    String status = candidate['status']?.toString() ?? 'Pending';

    // Determining visual badge based on actual application status
    Color statusBgColor = Colors.orange.shade50;
    Color statusTextColor = Colors.orange.shade700;
    IconData statusIcon = Icons.pending_actions;

    if (status == 'Hired') {
      statusBgColor = Colors.green.shade50;
      statusTextColor = Colors.green.shade700;
      statusIcon = Icons.check_circle;
    } else if (status == 'Rejected') {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade700;
      statusIcon = Icons.cancel;
    } else if (status == 'Reviewed' || status == 'Interviewing') {
      statusBgColor = Colors.blue.shade50;
      statusTextColor = Colors.blue.shade700;
      statusIcon = Icons.remove_red_eye;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Pic & View Profile Link underneath
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      _getInitials(candidate['first_name'], 1),
                      style: TextStyle(
                        color: primaryAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showResumeProfile(context, candidate, fullName),
                    child: Text(
                      "View Profile",
                      style: TextStyle(
                        color: primaryAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline, // Makes it look like a link
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              // 2. Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${candidate['email'] ?? 'No email'} | ${candidate['contact_number'] ?? 'No phone'}",
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // 3. Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusTextColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Pushes buttons to the right
            children: [
              // UPDATE STATUS BUTTON
              PopupMenuButton<String>(
                tooltip: "Update Application Status",
                onSelected: (String newStatus) {
                  provider.updateApplicationStatus(
                    candidate['application_id'],
                    newStatus,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Status updated to $newStatus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Pending Evaluation',
                        child: Text('Pending Evaluation'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Shortlisted',
                        child: Text('Shortlisted'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Hired',
                        child: Text('Hired'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Not Selected',
                        child: Text('Not Selected'),
                      ), 
                    ],
                child: Container(
                  height: 40, // FORCED HEIGHT TO MATCH X BUTTON
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: successGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.update, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Update Status",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // X / QUICK REJECT BUTTON
              Container(
                height: 40, // FORCED HEIGHT TO MATCH UPDATE BUTTON
                width: 40,  // Fixed width to make it a perfect square
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero, // Removes default padding so icon fits perfectly
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () {
                    provider.updateApplicationStatus(
                      candidate['application_id'],
                      'Rejected',
                    );
                  },
                  tooltip: "Quick Reject",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW PROFILE (RESUME) DIALOG
  // ==========================================
  void _showResumeProfile(BuildContext context, Map<String, dynamic> candidate, String fullName) {
    // 1. ADD THIS TO INSPECT THE DATA STRUCTURE IN YOUR TERMINAL
    debugPrint("FULL CANDIDATE DATA: $candidate");

    // 2. Add a fallback: Look for 'seeker_id', then 'id', then 'seekerId'
    final dynamic idValue = candidate['seeker_id'] ?? candidate['id'] ?? candidate['seekerId'];
    
    final int? seekerId = idValue != null ? int.tryParse(idValue.toString()) : null;

    if (seekerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Applicant ID not found in data.")),
      );
      return; // Stop here if no ID
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: cardWhite,
          child: Container(
            width: 700, 
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85), // Prevent overflow
            child: Column(
              children: [
                // Header (Same as before)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: sidebarBlue, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: sidebarBlue)),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 5),
                                Expanded(child: Text(candidate['email'] ?? 'Not provided', style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 10),
                                const Icon(Icons.phone_outlined, color: Colors.white70, size: 16),
                                const SizedBox(width: 5),
                                Text(candidate['contact_number'] ?? 'Not provided', style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Body - FutureBuilder for Real Data
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                      // Replace YOUR_BACKEND_IP with your actual server IP or localhost
                      future: http.get(Uri.parse('http://localhost:3000/api/seekers/$seekerId/full-profile'))
                                  .then((res) => jsonDecode(res.body)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading profile: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                        }

                        final data = snapshot.data!;
                        final edu = data['education'] ?? {};
                        final exps = data['work_experience'] ?? [];
                        final skills = data['other_skills'] ?? {};

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Education Section
                              _buildResumeSection(
                                Icons.school, 
                                "Educational Background", 
                                edu.isEmpty 
                                    ? "No education data provided." 
                                    : "Tertiary: ${edu['tert_school'] ?? 'N/A'}\nCourse: ${edu['tert_course'] ?? 'N/A'}\nGraduated: ${edu['tert_year_grad'] ?? 'N/A'}\n\nSecondary: ${edu['sec_school'] ?? 'N/A'}\nGraduated: ${edu['sec_year_grad'] ?? 'N/A'}"
                              ),
                              const Divider(height: 40),
                              
                              // Experience Section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.work, color: sidebarBlue, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Work Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        exps.isEmpty 
                                          ? Text("No work experience recorded.", style: TextStyle(color: textMuted))
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: (exps as List).map((exp) => Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  "• ${exp['position']} at ${exp['company_name']}\n  (${exp['date_from']} to ${exp['date_to']}) - ${exp['status']}",
                                                  style: TextStyle(color: textMuted, height: 1.5),
                                                ),
                                              )).toList(),
                                            )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 40),
                              
                              // Skills Section
                              _buildResumeSection(
                                Icons.build, 
                                "Skills & Competencies", 
                                skills.isEmpty || skills['skills_list'] == null
                                    ? "No specific skills listed." 
                                    : "${skills['skills_list']}\nOthers: ${skills['others_specify'] ?? 'None'}"
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Close", style: TextStyle(color: textMuted))),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF Generation pending implementation.")));
                        },
                        icon: const Icon(Icons.download, size: 16, color: Colors.white),
                        label: const Text("Download PDF", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: sidebarBlue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Update the resume section helper to handle multiline text better
  Widget _buildResumeSection(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: sidebarBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(content, style: TextStyle(color: textMuted, fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

   

  // 1. ADD THIS METHOD TO GENERATE THE TABLE
  Widget _buildJobSeekersTable(List<dynamic> allApps) {
    // Extract unique seekers from applications
    final Map<String, Map<String, dynamic>> uniqueSeekersMap = {};
    for (var app in allApps) {
      final email = app['email']?.toString() ?? 'Unknown';
      if (!uniqueSeekersMap.containsKey(email)) {
        uniqueSeekersMap[email] = {
          'first_name': app['first_name'] ?? 'Unknown',
          'last_name': app['last_name'] ?? 'Applicant',
          'email': email,
          'contact_number': app['contact_number'] ?? 'N/A',
          'education': 'College Graduate', // Placeholder
          'experience': '2 years', // Placeholder
          'status': 'Active', // Placeholder
        };
      }
    }

    List<Map<String, dynamic>> seekersList = uniqueSeekersMap.values.where((s) {
      final name = "${s['first_name']} ${s['last_name']}".toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registered Job Seekers",
            style: TextStyle(
              color: textDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          // TABLE UI
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
                            "NAME",
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
                            "CONTACT",
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
                            "EDUCATION",
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
                            "EXPERIENCE",
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
                    child: ListView.separated(
                      itemCount: seekersList.length,
                      separatorBuilder: (c, i) =>
                          Divider(color: Colors.grey.shade200, height: 1),
                      itemBuilder: (c, i) {
                        final s = seekersList[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${s['first_name']} ${s['last_name']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    Text(
                                      s['email'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  s['contact_number'],
                                  style: TextStyle(color: textMuted),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  s['education'],
                                  style: TextStyle(color: textMuted),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  s['experience'],
                                  style: TextStyle(color: textMuted),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s['status'],
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_red_eye,
                                        size: 16,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: () {},
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
  } // ==========================================

  // MATCHING VIEW (Placeholder for your code)
  // ==========================================
// --- ADDED: THE JOB MATCHING INTERFACE BACK ---
  Widget _buildJobMatchingContent(List<dynamic> activeJobs, List<dynamic> allApps, VacancyProvider provider) {
    int pendingCount = allApps.where((a) => a['status'] == 'Pending Evaluation').length;
    int hiredCount = allApps.where((a) => a['status'] == 'Hired').length;
    int totalApps = allApps.length;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(), // The Auto-Match button header
          const SizedBox(height: 25),
          _buildStatsRow(totalApps, hiredCount, pendingCount),
          const SizedBox(height: 25),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftPane(activeJobs, allApps), // Available Jobs List
                const SizedBox(width: 25),
                _buildRightPane(activeJobs, allApps, provider), // Candidate Matches
              ],
            ),
          ),
        ],
      ),
    );
  }
}
