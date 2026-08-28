import 'package:flutter/material.dart';

import '../seeker_dashboard.dart';
import '../seeker_myapplications.dart';
import '../seeker_profile.dart';

class SeekerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  const SeekerAppBar({super.key, required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(85);

  @override
  Widget build(BuildContext context) {
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
              // Dashboard Navigation Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenSeekerDashboard(),
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

              // My Application Navigation Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScreenSeekerMyApplications(),
                    ),
                  );
                },
                child: const Text(
                  "My Applications",
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
                    onLogout();
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
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
    );
  }
}
