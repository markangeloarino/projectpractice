import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neis_cap/screen_login.dart';
import 'package:neis_cap/screen_singup.dart';

class ScreenJobDetails extends StatelessWidget {
  final Map<String, dynamic> job;

  const ScreenJobDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Parse Date
    String postedDate = 'N/A';
    if (job['date_posted'] != null) {
      postedDate = DateFormat(
        'd MMMM yyyy',
      ).format(DateTime.parse(job['date_posted'].toString()).toLocal());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Center(
        // Centers the content
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Matches AppBar constraint
          child: SingleChildScrollView(
            // Removed horizontal padding here to allow the ConstrainedBox to handle alignment
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                          const SizedBox(height: 20),
                          _buildContentCard(
                            "Job Description",
                            job['job_description'] ?? 'No description.',
                            postedDate,
                          ),
                          _buildContentCard(
                            "Qualifications",
                            job['qualifications'] ?? 'No qualifications.',
                            null,
                          ),  
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),

                    // RIGHT COLUMN: Sidebar
                    Expanded(flex: 1, child: _buildSidebar(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                  job['job_title']?.toUpperCase() ?? 'JOB TITLE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  job['employer_name'] ?? 'EMPLOYER NAME',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['location'] ?? 'Location not specified',
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

  Widget _buildSidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apply Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScreenLogin()),
              );
            },
            child: const Text(
              "APPLY NOW",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Job Stats (rest of your sidebar items...)
          _buildSidebarItem(
            "Years of Experience",
            job['years_experience']?.toString() ?? '0',
          ),
          _buildSidebarItem("Salary", job['salary'] ?? 'Not specified'),
          _buildSidebarItem(
            "Vacancies",
            job['vacancies_count']?.toString() ?? '1',
          ),
          // _buildSidebarItem("Job Status", currentStatus),
          _buildSidebarItem(
            "Job Scope",
            job['job_location_type'] ?? 'N/A',
          ),
          _buildSidebarItem("Job Type", job['employment_type'] ?? 'N/A'),


          const Divider(height: 30),

          // Employer Career Website (Optional)
          if (job['employer_career_link'] != null &&
              job['employer_career_link'].toString().isNotEmpty) ...[
            const Text(
              "Career Website",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                /* Add URL launcher here */
              },
              child: Text(job['employer_career_link']),
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
}
