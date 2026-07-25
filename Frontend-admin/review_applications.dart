
import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';
import 'package:provider/provider.dart';
 
class ScreenReviewApplications extends StatefulWidget {
  const ScreenReviewApplications({super.key});

  @override
  State<ScreenReviewApplications> createState() => _ScreenReviewApplicationsState();
}

class _ScreenReviewApplicationsState extends State<ScreenReviewApplications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacancyProvider>().fetchAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VacancyProvider>();
    final applications = provider.allApplications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Applications"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : applications.isEmpty
                ? const Center(child: Text("No applications found."))
                : ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${app['first_name']} ${app['last_name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text("Applied for: ${app['job_title']} at ${app['employer_name']}", style: TextStyle(color: Colors.grey.shade700)),
                                  Text("Email: ${app['email']} | Phone: ${app['contact_number'] ?? 'N/A'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildStatusBadge(app['status'] ?? 'Pending'),
                                  const SizedBox(width: 20),
                                  DropdownButton<String>(
                                    hint: const Text("Change Status"),
                                    items: ['Pending', 'Reviewed', 'Interviewing', 'Hired', 'Rejected']
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        provider.updateApplicationStatus(app['application_id'], newStatus);
                                      }
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'Pending') color = Colors.orange;
    else if (status == 'Hired') color = Colors.green;
    else if (status == 'Rejected') color = Colors.red;
    else color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}