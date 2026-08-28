import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Frontend-jobposting/post_vacancy_provider.dart';
import '../auth_provider.dart';
import '../screen_login.dart';
import 'widget/app_bar.dart';

class ScreenSeekerJobDetails extends StatefulWidget {
  final Map<String, dynamic> job;

  const ScreenSeekerJobDetails({super.key, required this.job});

  @override
  State<ScreenSeekerJobDetails> createState() => _ScreenSeekerJobDetailsState();
}

class _ScreenSeekerJobDetailsState extends State<ScreenSeekerJobDetails> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = authProvider.currentUser;

    // Parse Date
    String postedDate = 'N/A';
    if (widget.job['date_posted'] != null) {
      postedDate = DateFormat(
        'd MMMM yyyy',
      ).format(DateTime.parse(widget.job['date_posted'].toString()).toLocal());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: SeekerAppBar(
        onLogout: () {
          authProvider.currentUser = null;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ScreenLogin()),
          );
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1300
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        _buildContentCard(
                          "Job Description",
                          widget.job['job_description'] ?? 'No description.',
                          postedDate,
                        ),
                        _buildContentCard(
                          "Qualifications",
                          widget.job['qualifications'] ??
                              'No qualifications.',
                          null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
          
                  // RIGHT COLUMN: Sidebar
                  Expanded(
                    flex: 1,
                    child: _buildSidebar(context, user, vacancyProvider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job details",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: const Icon(Icons.business, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job['job_title']?.toUpperCase() ?? 'JOB TITLE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  widget.job['employer_name'] ?? 'EMPLOYER NAME',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.job['location'] ?? 'Location not specified',
                        style: const TextStyle(fontSize: 14),
                        softWrap: true, //
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add this to your ScreenJobDetails class
  Widget _buildContentCard(String title, String content, String? date) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (date != null)
                Text(
                  "Posted on $date",
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
          const Divider(height: 30),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    Map<String, dynamic>? user,
    VacancyProvider provider,
  ) {
    // 1. Safely grab the status and check if it is closed
    final String currentStatus = widget.job['status'] ?? 'Active';
    final bool isClosed = currentStatus == 'Closed';

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. The Apply Button logic
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: isClosed ? Colors.white : Colors.green,
              disabledBackgroundColor: Colors.red,
            ),
            // Passing 'null' to onPressed automatically disables the button making it unclickable
            onPressed: isClosed
                ? null
                : () => _apply(user, widget.job, provider),
            child: Text(
              isClosed ? "CLOSED" : "APPLY NOW",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Note: Make sure that your profile is always updated!",
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Job Stats (rest of your sidebar items...)
          _buildSidebarItem(
            "Years of Experience",
            widget.job['years_experience']?.toString() ?? '0',
          ),
          _buildSidebarItem("Salary", widget.job['salary'] ?? 'Not specified'),
          _buildSidebarItem(
            "Vacancies",
            widget.job['vacancies_count']?.toString() ?? '1',
          ),
          // _buildSidebarItem("Job Status", currentStatus),
          _buildSidebarItem(
            "Job Scope",
            widget.job['job_location_type'] ?? 'N/A',
          ),
          _buildSidebarItem("Job Type", widget.job['employment_type'] ?? 'N/A'),

          const Divider(height: 30),

          // Employer Career Website (Optional)
          if (widget.job['employer_career_link'] != null &&
              widget.job['employer_career_link'].toString().isNotEmpty) ...[
            const Text(
              "Career Website",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                /* Add URL launcher here */
              },
              child: Text(widget.job['employer_career_link']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
