import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Frontend-jobposting/post_vacancy_provider.dart';
import '../auth_provider.dart';
import '../screen_login.dart';
import 'widget/app_bar.dart';
import 'seeker_job_details.dart';

class ScreenSeekerMyApplications extends StatefulWidget {
  const ScreenSeekerMyApplications({super.key});

  @override
  State<ScreenSeekerMyApplications> createState() =>
      _ScreenSeekerMyApplicationsState();
}

class _ScreenSeekerMyApplicationsState extends State<ScreenSeekerMyApplications> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
// Handle application deletion locally and trigger API update
 Future<void> _handleRemoveApplication(
      BuildContext context, Map<String, dynamic> app, VacancyProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Application"),
        content: Text("Are you sure you want to remove your application for ${app['job_title'] ?? 'this job'}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final jobId = int.parse(app['job_id'].toString());
        final user = context.read<AuthProvider>().currentUser;
        final seekerId = int.parse((user?['seeker_id'] ?? user?['id']).toString());

        await provider.cancelApplication(jobId, seekerId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Application removed successfully."), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Could not connect to backend."), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final vacancyProvider = context.watch<VacancyProvider>();
    final user = authProvider.currentUser;

    // Filter application list based on search query
    final filteredApps = vacancyProvider.myApplications.where((app) {
      final title = app['job_title']?.toString().toLowerCase() ?? '';
      final employer = app['employer_name']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) ||
          employer.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: _buildMyApplicationsTab(vacancyProvider, user, filteredApps),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyApplicationsTab(
    VacancyProvider vacancyProvider,
    Map<String, dynamic>? user,
    List<dynamic> filteredApps,
  ) {
    if (vacancyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vacancyProvider.myApplications.isEmpty && _searchQuery.isEmpty) {
      return Center(
        child: Text(
          "You haven't applied to any jobs yet.\nBrowse job vacancies to find your next opportunity!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
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
              const Text(
                "Track the status of the jobs you have applied for.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search your applications...",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              Text(
                "${filteredApps.length} APPLIED JOBS",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF343A40),
                ),
              ),
              const Divider(color: Color(0xFFDEE2E6), thickness: 1, height: 16),
            ],
          ),
        ),
        Expanded(
          child: filteredApps.isEmpty
              ? const Center(
                  child: Text(
                    "No applications match your search query.",
                    style: TextStyle(fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    return _buildApplicationHistoryCard(
                        context, filteredApps[index], vacancyProvider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildApplicationHistoryCard(
      BuildContext context, Map<String, dynamic> app, VacancyProvider provider) {
    String formattedDate = 'N/A';
    if (app["applied_at"] != null) {
      try {
        DateTime parsedDate = DateTime.parse(app["applied_at"].toString()).toLocal();
        formattedDate = DateFormat('MMM d, yyyy').format(parsedDate);
      } catch (_) {}
    }

    String status = app['status']?.toString() ?? 'Pending';
    Color statusColor = Colors.orange;
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

 return InkWell(
      onTap: () {
        // Show a pop-up dialog with job details and a CLOSE button
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text(
              (app['job_title'] ?? 'Job Details').toString().toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Employer: ${(app['employer_name'] ?? 'Unknown Employer').toString().toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text("Applied on: $formattedDate"),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      "Current Status: ${status.toUpperCase()}",
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        // ... Keep the rest of your Container UI exactly as it is
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.business_center_outlined,
                color: Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (app['job_title'] ?? 'Unknown Job').toString().toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (app['employer_name'] ?? 'Unknown Employer').toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Applied on: $formattedDate",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
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
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _handleRemoveApplication(context, app, provider),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}