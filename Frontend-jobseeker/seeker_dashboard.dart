import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Frontend-jobposting/post_vacancy_provider.dart';
import '../Home/screen_login.dart';
import '../auth_provider.dart';
 import 'seeker_job_details.dart';
import 'widget/app_bar.dart';

class ScreenSeekerDashboard extends StatefulWidget {
  const ScreenSeekerDashboard({super.key});

  @override
  State<ScreenSeekerDashboard> createState() => _ScreenSeekerDashboardState();
}

class _ScreenSeekerDashboardState extends State<ScreenSeekerDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Tracks which tab is active. 1 = Browse more jobs, 4 = Job applications
  int _currentTabIndex = 1; 

  final List<String> _dashboardTabs = [
    "Matched jobs",
    "Browse more jobs",
    "Saved jobs",
    "Job invitations",
    "Job applications"
  ];

  // Checkbox states for Browse Jobs
  bool _isPwd = false;
  bool _isDisplaced = false;
  bool _isHighSchool = false;
  bool _isGov = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vacancyProvider = context.read<VacancyProvider>();
      final authProvider = context.read<AuthProvider>();

      vacancyProvider.fetchVacancies();
      final user = authProvider.currentUser;
      if (user != null) {
        final seekerId = user['seeker_id'] ?? user['id'];
        if (seekerId != null) {
          vacancyProvider.fetchMyApplications(int.parse(seekerId.toString()));
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = authProvider.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredJobs = vacancyProvider.activeJobs.where((job) {
      final title = job['job_title']?.toString().toLowerCase() ?? '';
      final employer = job['employer_name']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) ||
          employer.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: SeekerAppBar(
        onLogout: () {
          authProvider.currentUser = null;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ScreenLogin()),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PAGE HEADER
                  Text(
                    "Hello, ${user?['first_name'] ?? 'Mark Angelo'} ${user?['last_name'] ?? 'P. Ariño'}",
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF343A40)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  // 2-COLUMN LAYOUT (Left Sidebar + Expanded Middle Content)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. LEFT SIDEBAR (Tabs + Preferences)
                      if (screenWidth > 700) ...[
                        SizedBox(
                          width: 260, // Slightly wider to accommodate preference text
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeftSidebarNav(),
                              const SizedBox(height: 40),
                              // Preferences moved below the tabs
                              _buildPreferencesSummary(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],

                      // 2. MIDDLE CONTENT (Expanded to fill the rest of the screen)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(30.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          // --- TAB ROUTING LOGIC ---
                          child: _currentTabIndex == 1
                              ? _buildBrowseJobsTab(vacancyProvider, user, filteredJobs)
                              : _currentTabIndex == 4
                                  ? _buildJobApplicationsTab(vacancyProvider)
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Text(
                                          "${_dashboardTabs[_currentTabIndex]} section is under construction.",
                                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. VERTICAL NAVIGATION MENU (LEFT SIDEBAR) ---
  Widget _buildLeftSidebarNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_dashboardTabs.length, (index) {
          bool isActive = _currentTabIndex == index;
          return InkWell(
            onTap: () {
              setState(() {
                _currentTabIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.withOpacity(0.05) : Colors.white,
                border: Border(
                  bottom: index == _dashboardTabs.length - 1
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade200),
                  left: isActive
                      ? const BorderSide(color: Colors.blue, width: 4)
                      : const BorderSide(color: Colors.transparent, width: 4),
                ),
              ),
              child: Text(
                _dashboardTabs[index],
                style: TextStyle(
                  color: isActive ? Colors.blue.shade700 : Colors.black54,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- PREFERENCES SUMMARY (Moved to Left Sidebar) ---
  Widget _buildPreferencesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PREFERRED POSITIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• ", style: TextStyle(fontSize: 14)),
            Expanded(child: Text("INFORMATION AND COMMUNICATION TECHNOLOGY MANAGER", style: TextStyle(fontSize: 12, color: Colors.black87))),
          ],
        ),
        const SizedBox(height: 30),
        
        const Text("PREFERRED WORK LOCATIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
        const SizedBox(height: 12),
        _buildBulletText("NAGA CITY, CAMARINES SUR"),
        _buildBulletText("DUMANGAS, ILOILO"),
        _buildBulletText("NEW LUCENA, ILOILO"),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.edit, size: 14, color: Colors.blue),
            SizedBox(width: 6),
            Text("Edit job preferences", style: TextStyle(fontSize: 13, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 30),
        
        const Text("CREATE A FREE RESUME", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.download, size: 14, color: Colors.blue),
            SizedBox(width: 6),
            Text("Download resume", style: TextStyle(fontSize: 13, color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  // --- 2. BROWSE JOBS TAB CONTENT ---
  Widget _buildBrowseJobsTab(VacancyProvider vacancyProvider, Map<String, dynamic>? user, List<dynamic> filteredJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "You may search by position title, employer name, work location, education level or course, etc.",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _searchQuery = _searchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9ECEF),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text("Search"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 16,
          children: [
            _buildCheckbox("PWDs", _isPwd, (val) => setState(() => _isPwd = val!)),
            _buildCheckbox("Displaced workers", _isDisplaced, (val) => setState(() => _isDisplaced = val!)),
            _buildCheckbox("High school graduates", _isHighSchool, (val) => setState(() => _isHighSchool = val!)),
            _buildCheckbox("Government jobs", _isGov, (val) => setState(() => _isGov = val!)),
          ],
        ),
        const SizedBox(height: 24),
        
        Text(
          "${vacancyProvider.activeJobs.length} JOB OPENINGS",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF343A40)),
        ),
        const Divider(color: Color(0xFFDEE2E6), thickness: 1, height: 24),
        
        vacancyProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vacancyProvider.errorMessage != null
                ? Center(child: Text(vacancyProvider.errorMessage!, style: const TextStyle(color: Colors.red)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      return _buildJobCard(filteredJobs[index]);
                    },
                  ),
      ],
    );
  }

  // --- 3. JOB APPLICATIONS TAB CONTENT ---
  Widget _buildJobApplicationsTab(VacancyProvider vacancyProvider) {
    final applications = vacancyProvider.myApplications ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Job Applications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
        ),
        const SizedBox(height: 8),
        const Text(
          "View and track the status of your submitted job applications.",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        
        Text(
          "${applications.length} APPLICATIONS",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF343A40)),
        ),
        const Divider(color: Color(0xFFDEE2E6), thickness: 1, height: 24),
        
        vacancyProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : applications.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("You haven't applied to any jobs yet.", style: TextStyle(color: Colors.black54)),
                    ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(applications[index]);
                    },
                  ),
      ],
    );
  }

  // --- PHILJOBNET STYLE JOB SEARCH CARD ---
  Widget _buildJobCard(Map<String, dynamic> job) {
    String formattedDate = 'Posted on N/A';
    if (job["date_posted"] != null) {
      try {
        DateTime parsedDate = DateTime.parse(job["date_posted"].toString()).toLocal();
        formattedDate = "Posted on ${DateFormat('M/d/yyyy').format(parsedDate)}";
      } catch (e) {}
    }

    String status = (job['status'] ?? 'ACTIVE').toUpperCase();
    bool isActive = status == 'ACTIVE';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScreenSeekerJobDetails(job: job)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
              child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (job['job_title'] ?? 'UNKNOWN TITLE').toUpperCase(),
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        job['salary'] != null ? "₱${job['salary']}" : "Salary not specified",
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          (job['employer_name'] ?? 'UNKNOWN EMPLOYER').toUpperCase(),
                          style: TextStyle(color: Colors.blue.shade400, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildIconText(Icons.location_on_outlined, job['location'] ?? 'NAGA CITY, CAMARINES SUR'),
                            _buildIconText(Icons.school_outlined, job['qualifications'] ?? 'EDUCATION NOT SPECIFIED'),
                            _buildIconText(Icons.description_outlined, job['employment_type'] ?? 'FULL-TIME'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                          border: Border.all(color: isActive ? Colors.green.shade300 : Colors.red.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: isActive ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MY APPLICATIONS CARD ---
  Widget _buildApplicationCard(Map<String, dynamic> app) {
    String appStatus = (app['application_status'] ?? app['status'] ?? 'PENDING').toUpperCase();
    
    Color statusColor = Colors.orange;
    if (appStatus == 'HIRED' || appStatus == 'ACCEPTED' || appStatus == 'APPROVED') statusColor = Colors.green;
    if (appStatus == 'REJECTED' || appStatus == 'DECLINED') statusColor = Colors.red;

    String dateApplied = 'N/A';
    if (app['date_applied'] != null || app['created_at'] != null) {
      try {
        DateTime parsed = DateTime.parse((app['date_applied'] ?? app['created_at']).toString()).toLocal();
        dateApplied = DateFormat('M/d/yyyy').format(parsed);
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.work_outline, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (app['job_title'] ?? 'UNKNOWN TITLE').toUpperCase(),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  (app['employer_name'] ?? 'UNKNOWN EMPLOYER').toUpperCase(),
                  style: TextStyle(color: Colors.blue.shade400, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Applied on $dateApplied", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              border: Border.all(color: statusColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              appStatus,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildIconText(IconData icon, String text) {
    String displayText = text.length > 38 ? '${text.substring(0, 38)}...' : text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.blue),
        const SizedBox(width: 4),
        Text(displayText.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }
}