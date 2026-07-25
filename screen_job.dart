import 'package:flutter/material.dart';
import 'package:neis_cap/screen_job_details.dart';
import 'package:provider/provider.dart';
import 'package:neis_cap/screen_login.dart';
import 'package:neis_cap/screen_singup.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';
import 'package:intl/intl.dart'; // NEW: Required for formatting the date

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  // Theme Colors based on the new layout
  final Color darkHeader = const Color(0xFF1E1E1E);
  final Color primaryBlue = const Color(0xFF2B89E2);
  final Color textDark = const Color(0xFF333333);
  final Color textMuted = const Color(0xFF666666);
  final Color bgLight = const Color(0xFFFFFFFF);

  // Checkbox states for search filters
  bool isPwd = false;
  bool isDisplaced = false;
  bool isHighSchool = false;
  bool isGov = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacancyProvider>().fetchVacancies();
      context.read<VacancyProvider>().fetchEmployers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vacancyProvider = context.watch<VacancyProvider>();

    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Main Content (70% width)
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(),
                        const SizedBox(height: 30),
                        _buildSearchSection(),
                        const SizedBox(height: 30),
                        _buildJobCount(vacancyProvider),
                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 10),
                        _buildJobsList(vacancyProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // APP BAR (Dark Theme)
  // ==========================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
              // Nav Links
              _buildNavLink("Home", isActive: true),
              _buildNavLink("Jobs"),
              const SizedBox(width: 20),
              // Action Buttons (Moved inside the ConstrainedBox)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenSignup(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: const BorderSide(color: Colors.black, width: 2.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenLogin(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                child: Text("LOGIN", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 30,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  // ==========================================
  // LEFT COLUMN: Header & Search
  // ==========================================
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job vacancies",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Find jobs here",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You may search by position title, employer name, work location, education level or course, etc.",
          style: TextStyle(fontSize: 14, color: textMuted),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: TextField(
                  controller: _searchController, // 2. ADD CONTROLLER
                  onChanged: (value) =>
                      setState(() => _searchQuery = value), // 3. ADD THIS
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: TextButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // ==========================================
  // LEFT COLUMN: Job List
  // ==========================================
  Widget _buildJobCount(VacancyProvider provider) {
    return Text(
      "${provider.activeJobs.length} JOB OPENINGS",
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildJobsList(VacancyProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.activeJobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(
          "No job opportunities available right now.",
          style: TextStyle(fontSize: 16, color: textMuted),
        ),
      );
    }

    final filteredJobs = provider.activeJobs.where((job) {
      final title = job['job_title']?.toString().toLowerCase() ?? '';
      final employer = job['employer_name']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return title.contains(query) || employer.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text("No jobs match your search.")),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredJobs.length, // 6. USE filteredJobs HERE
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.black12, height: 40),
      itemBuilder: (context, index) {
        return _buildJobCard(filteredJobs[index]); // 7. USE filteredJobs HERE
      },
    );
  }

 // The newly styled job card matching the mockup
  Widget _buildJobCard(
    Map<String, dynamic> job,
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
            builder: (context) => ScreenJobDetails(job: job),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClosed ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isClosed ? Colors.red.shade200 : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isClosed ? Colors.red.shade700 : Colors.green.shade700,
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
        Icon(icon, size: 14, color: Colors.blue),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
