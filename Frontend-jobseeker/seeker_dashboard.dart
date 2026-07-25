import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';
import 'package:neis_cap/Frontend-jobseeker/seeker_profile.dart';
import 'package:neis_cap/Frontend-jobseeker/seeker_job_details.dart';
import 'package:neis_cap/auth_provider.dart';
import 'package:provider/provider.dart';
import '../screen_login.dart';

class ScreenSeekerDashboard extends StatefulWidget {
  const ScreenSeekerDashboard({super.key});

  @override
  State<ScreenSeekerDashboard> createState() => _ScreenSeekerDashboardState();
}

class _ScreenSeekerDashboardState extends State<ScreenSeekerDashboard> {
  // State for the active tab (0: Browse more jobs, 1: Saved jobs, 2: Job applications)
  int _activeTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Fetch both the active jobs and the user's application history when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vacancyProvider = context.read<VacancyProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // 1. Fetch public jobs
      vacancyProvider.fetchVacancies();
      
      // 2. Fetch the logged-in user's specific application history
      final user = authProvider.currentUser;
      if (user != null) {
        final seekerId = user['seeker_id'] ?? user['id'];
        if (seekerId != null) {
          vacancyProvider.fetchMyApplications(int.parse(seekerId.toString()));
        }
      }
    });
    // Fetch the jobs exactly when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacancyProvider>().fetchVacancies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = authProvider.currentUser;

    final filteredJobs = vacancyProvider.activeJobs.where((job) {
      final title = job['job_title']?.toString().toLowerCase() ?? '';
      final employer = job['employer_name']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) ||
          employer.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        elevation: 0,
        toolbarHeight: 85,
        automaticallyImplyLeading: false,
        titleSpacing: 0, // Removes default edge padding so it aligns perfectly
        centerTitle: true,
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Matches the body container
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ), // Matches body padding
            child: Row(
              children: [
                // Official Seals / Logos
                Image.asset('assets/naga.png', height: 70, fit: BoxFit.contain),
                const SizedBox(width: 10),
                Image.asset('assets/peso.png', height: 70, fit: BoxFit.contain),
                const SizedBox(width: 15),
                // Logo Text
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Naga Job",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Dashboard Navigation Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenSeekerProfile(),
                      ),
                    );
                  },
                  child: const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Profile Navigation Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenSeekerProfile(),
                      ),
                    );
                  },
                  child: const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Dropdown Menu triggered by the Profile Picture Circle (Now only for Logout)
                PopupMenuButton<String>(
                  offset: const Offset(
                    0,
                    50,
                  ), // Pushes the dropdown slightly below the app bar
                  tooltip: 'Account Menu',
                  onSelected: (String value) {
                    if (value == 'logout') {
                      authProvider.currentUser = null;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScreenLogin(),
                        ),
                      );
                    }
                  },
                  // The Profile Picture Circle
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF0D47A1),
                      ), // Using an icon until a real image is added
                    ),
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${user?['first_name'] ?? 'Mark Angelo'} ${user?['last_name'] ?? 'P. Ariño'}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Job Seeker",
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double
                      .infinity, // Ensures the border goes all the way across
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFDEE2E6), width: 1.5),
                    ),
                  ),
                  child: SingleChildScrollView(
                    // <-- This prevents the text from disappearing on small screens!
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabDashboard("Browse more jobs", 0),
                        _buildTabDashboard("My applications", 1),
                      ],
                    ),
                  ),
                ),
              ),

              // Dynamic Content Area based on selected tab
              // Dynamic Content Area based on selected tab
              Expanded(
                child: _activeTabIndex == 0
                    ? _buildBrowseJobsTab(vacancyProvider, user, filteredJobs)
                    : _buildMyApplicationsTab(vacancyProvider), // <-- Replaced the placeholder text!
              ),
            ],
          ),
        ),
      ),
    );
  }
// ==========================================
  // "MY APPLICATIONS" TAB UI
  // ==========================================
  Widget _buildMyApplicationsTab(VacancyProvider vacancyProvider) {
    if (vacancyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vacancyProvider.myApplications.isEmpty) {
      return Center(
        child: Text(
          "You haven't applied to any jobs yet.\nBrowse the job vacancies to find your next opportunity!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Application History",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Track the status of the jobs you have applied for.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFDEE2E6), thickness: 1),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: vacancyProvider.myApplications.length,
            itemBuilder: (context, index) {
              final app = vacancyProvider.myApplications[index];
              return _buildApplicationHistoryCard(app);
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // INDIVIDUAL APPLICATION HISTORY CARD
  // ==========================================
  Widget _buildApplicationHistoryCard(Map<String, dynamic> app) {
    // 1. Format the Date safely
    String formattedDate = 'N/A';
    if (app["applied_at"] != null) {
      try {
        DateTime parsedDate = DateTime.parse(app["applied_at"].toString()).toLocal();
        formattedDate = DateFormat('MMM d, yyyy').format(parsedDate);
      } catch (e) {}
    }

    // 2. Determine the status and apply the correct color
    String status = app['status']?.toString() ?? 'Pending';
    Color statusColor = Colors.orange; // Default for Pending
    Color statusBg = Colors.orange.shade50;

    if (status == 'Hired' || status == 'Approved') {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade50;
    } else if (status == 'Rejected' || status == 'Not Selected') {
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade50;
    } else if (status == 'Reviewed' || status == 'Shortlisted') {
      statusColor = Colors.blue.shade700;
      statusBg = Colors.blue.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: const Icon(Icons.business_center_outlined, color: Colors.grey, size: 28),
          ),
          const SizedBox(width: 20),
          
          // Middle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (app['job_title'] ?? 'Unknown Job').toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  (app['employer_name'] ?? 'Unknown Employer').toString().toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      "Applied on: $formattedDate",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Right Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget for creating the tabs
  Widget _buildTabDashboard(String title, int index) {
    bool isActive = _activeTabIndex == index;

    return InkWell(
      key: ValueKey('tab_$index'),
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          // color: isActive ? Colors.transparent : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: isActive ? const Color(0xFFDEE2E6) : Colors.transparent,
            ),
            left: BorderSide(
              color: isActive ? const Color(0xFFDEE2E6) : Colors.transparent,
            ),
            right: BorderSide(
              color: isActive ? const Color(0xFFDEE2E6) : Colors.transparent,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        child: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.red,
          ),
        ),
      ),
    );
  }

  // The content for the "Browse more jobs" section
  Widget _buildBrowseJobsTab(
    VacancyProvider vacancyProvider,
    Map<String, dynamic>? user,
    dynamic filteredJobs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Job vacancies",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "You may search by position title, employer name, work location, education level or course, etc.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              // Custom Search Bar Layout
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _searchQuery = _searchController.text);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8F9FA),
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text("Search"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Job Openings Header
              Text(
                "${vacancyProvider.activeJobs.length} JOB OPENINGS",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
              const Divider(color: Color(0xFFDEE2E6), thickness: 1, height: 16),
            ],
          ),
        ),

        // Live Job List
        Expanded(
          child: vacancyProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vacancyProvider.errorMessage != null
              ? Center(
                  child: Text(
                    vacancyProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : vacancyProvider.activeJobs.isEmpty
              ? const Center(
                  child: Text(
                    "No job vacancies have been encoded by Metro PESO staff yet.",
                    style: TextStyle(fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredJobs.length, // Use filteredJobs.length
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index]; // Use filteredJobs[index]
                    return _buildJobCard(job, user, vacancyProvider);
                  },
                ),
        ),
      ],
    );
  }

  // The newly styled job card matching the mockup
  Widget _buildJobCard(
    Map<String, dynamic> job,
    Map<String, dynamic>? user,
    VacancyProvider provider,
  ) {
    // Parse Date
    String formattedDate = 'Posted on N/A';
    if (job["date_posted"] != null) {
      try {
        DateTime parsedDate = DateTime.parse(
          job["date_posted"].toString(),
        ).toLocal();
        formattedDate =
            "Posted on ${DateFormat('M/d/yyyy').format(parsedDate)}";
      } catch (e) {}
    }

    // Determine Status
    String status = job['status'] ?? 'Active';
    bool isClosed = status == 'Closed';

    return InkWell(
      onTap: () {
        // You can add Navigator.push to ScreenJobDetails here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenSeekerJobDetails(job: job),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDEE2E6))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 20),

            // 2. Middle: Title, Employer, and even-distributed attributes
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (job['job_title'] ?? 'UNKNOWN TITLE').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    (job['employer_name'] ?? 'UNKNOWN EMPLOYER').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Evenly distributed attribute row
                  Row(
                    children: [
                      Expanded(
                        child: _buildIconText(
                          Icons.location_on_outlined,
                          job['location'] ?? 'Naga City',
                        ),
                      ),
                      Expanded(
                        child: _buildIconText(
                          Icons.school_outlined,
                          job['qualifications'] ?? 'Educ level not specified',
                        ),
                      ),
                      Expanded(
                        child: _buildIconText(
                          Icons.description_outlined,
                          job['employment_type'] ?? 'Job type not specified',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Right: Salary, Date, and Status (Perfectly aligned)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '₱',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        job["salary"] ?? 'Salary not specified',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // --- JOB STATUS BADGE ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isClosed
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isClosed
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blue.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: Color(0xFF495057)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Refactored apply logic for cleanliness
  Future<void> _apply(
    Map<String, dynamic>? user,
    Map<String, dynamic> job,
    VacancyProvider provider,
  ) async {
    final seekerId = user?['seeker_id'] ?? user?['id'];
    if (seekerId != null) {
      bool success = await provider.applyForJob(seekerId, job['vacancy_id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Applied successfully!"
                  : provider.errorMessage ?? "Error",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
