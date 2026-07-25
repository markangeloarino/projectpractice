import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-jobposting/sidebar/staff_employers_tab.dart';
import 'package:neis_cap/Frontend-jobposting/sidebar/staff_job_postings_tab.dart';
import 'package:neis_cap/Frontend-jobposting/sidebar/staff_overview_tab.dart';
import 'package:neis_cap/Frontend-jobposting/sidebar/staff_reports_tab.dart';
import 'package:provider/provider.dart';
import 'package:neis_cap/auth_provider.dart';
import 'package:neis_cap/screen_staff_login.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';

 

class ScreenJobPosterDashboard extends StatefulWidget {
  const ScreenJobPosterDashboard({super.key});

  @override
  State<ScreenJobPosterDashboard> createState() => _ScreenJobPosterDashboardState();
}

class _ScreenJobPosterDashboardState extends State<ScreenJobPosterDashboard> {
  int _selectedMenu = 0;

  final Color sidebarBlue = const Color(0xFF23367A); 
  final Color sidebarActive = const Color(0xFF334A99); 
  final Color mainBg = const Color(0xFFF5F7FB); 
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color primaryAccent = const Color(0xFF1D4ED8); 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VacancyProvider>().fetchVacancies();
      context.read<VacancyProvider>().fetchEmployers();
      context.read<VacancyProvider>().fetchAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedMenu == 6 ? 3 : (_selectedMenu > 3 ? 0 : _selectedMenu),
                    children: const [
                      StaffOverviewTab(),
                      Center(child: Text("Job Seekers Management under development.")),
                      StaffEmployersTab(),
                      StaffJobPostingsTab(),
                      StaffReportsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.account_balance, color: sidebarBlue, size: 20)),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PESO Naga", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Job Poster", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                _sidebarItem(2, Icons.business, "Employers"),
                _sidebarItem(3, Icons.work_outline, "Job Postings"),
                _sidebarItem(6, Icons.bar_chart, "Reports & Analytics"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: InkWell(
              onTap: () {
                context.read<AuthProvider>().currentUser = null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScreenStaffLogin()));
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
        decoration: BoxDecoration(color: isActive ? sidebarActive : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      color: cardWhite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Naga Job: Job Vacancies Management System",
            style: TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 15),
          ),
          Row(
            children: [
              Icon(Icons.notifications_none, color: textDark),
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 16, backgroundColor: primaryAccent,
                child: const Text("JD", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}