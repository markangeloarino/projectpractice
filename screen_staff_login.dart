import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-admin/admin_dashboard.dart';
import 'package:neis_cap/Frontend-jobmatching/matching_dashboard.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy.dart';
import 'package:provider/provider.dart';
import 'package:neis_cap/auth_provider.dart';
import 'Frontend-admin/admin_dashboard.dart';

// admin@naga.gov.ph
// admin123

class ScreenStaffLogin extends StatefulWidget {
  const ScreenStaffLogin({super.key});

  @override
  State<ScreenStaffLogin> createState() => _ScreenStaffLoginState();
}

class _ScreenStaffLoginState extends State<ScreenStaffLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // Set the requested background color
      backgroundColor: const Color.fromARGB(255, 44, 67, 151),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/peso.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                "Naga Job Portal ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Login Card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  margin: const EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (authProvider.errorMessage != null)
                          Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 20),
                        authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: Colors.blue.shade900,
                                  foregroundColor: Colors.white,
                                ),
                                // Make sure to import both dashboards at the top of your login screen:

                                // Inside your login button's onPressed:
                                onPressed: () async {
                                  String? role = await context
                                      .read<AuthProvider>()
                                      .staffLogin(
                                        _emailController.text,
                                        _passwordController.text,
                                      );

                                  if (!mounted) return;

                                  // ... inside the login onPressed function:
                                  // Inside your login onPressed function:
                                  if (role == 'Admin') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScreenAdminDashboard(),
                                      ),
                                    );
                                  } else if (role == 'Job Poster') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScreenJobPosterDashboard(),
                                      ),
                                    );
                                  } else if (role == 'Job Matcher') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScreenJobMatcherDashboard(),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// admin@naga.gov.ph
// admin123
