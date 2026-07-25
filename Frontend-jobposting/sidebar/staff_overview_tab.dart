import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';

class StaffOverviewTab extends StatelessWidget {
  const StaffOverviewTab({super.key});

  final Color mainBg = const Color(0xFFF5F7FB);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color primaryAccent = const Color(0xFF1D4ED8);
  final Color sidebarBlue = const Color(0xFF23367A);

  @override
  Widget build(BuildContext context) {
    final vacancyProvider = context.watch<VacancyProvider>();
    final allApps = vacancyProvider.allApplications;
    final activeJobs = vacancyProvider.activeJobs;

    int totalSeekers = allApps.map((a) => a['email']).toSet().length;
    int totalJobs = activeJobs.length;
    int pendingApps = allApps.where((a) => a['status'] == 'Pending').length;
    int hiredCount = allApps.where((a) => a['status'] == 'Hired').length;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatCard("Total Job Seekers", "$totalSeekers", primaryAccent, Icons.people),
              const SizedBox(width: 20),
              _buildStatCard("Active Vacancies", "$totalJobs", sidebarBlue, Icons.work),
              const SizedBox(width: 20),
              _buildStatCard("Pending Applications", "$pendingApps", Colors.orange, Icons.pending_actions),
              const SizedBox(width: 20),
              _buildStatCard("Total Placements", "$hiredCount", Colors.green, Icons.emoji_events),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Application Activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: allApps.isEmpty
                        ? Center(child: Text("No recent activity", style: TextStyle(color: textMuted)))
                        : ListView.separated(
                            itemCount: allApps.take(5).length,
                            separatorBuilder: (c, i) => const Divider(height: 20),
                            itemBuilder: (c, i) {
                              final app = allApps[i];
                              return Row(
                                children: [
                                  Icon(Icons.history, color: textMuted, size: 16),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${app['first_name']} applied for ${app['job_title']}",
                                    style: TextStyle(color: textDark),
                                  ),
                                  const Spacer(),
                                  Text(
                                    app['status'],
                                    style: TextStyle(color: primaryAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
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

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}