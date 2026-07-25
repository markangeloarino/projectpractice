import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-jobseeker/seeker_dashboard.dart';
import 'package:neis_cap/screen_job.dart';
import 'package:neis_cap/screen_login.dart';
import 'package:provider/provider.dart';
import 'package:neis_cap/auth_provider.dart';

class ScreenSignup extends StatefulWidget {
  const ScreenSignup({super.key});

  @override
  State<ScreenSignup> createState() => _ScreenSignupState();
}

class _ScreenSignupState extends State<ScreenSignup> {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      // ==========================================
      // REGISTRATION FORM
      // ==========================================
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sing Up",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _firstController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _lastController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

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

                const SizedBox(height: 30),

                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // 1. Clean the text inputs
                          final String firstName = _firstController.text.trim();
                          final String lastName = _lastController.text.trim();
                          final String email = _emailController.text.trim();
                          final String password = _passwordController.text
                              .trim();

                          // 2. Validate empty fields
                          if (firstName.isEmpty ||
                              lastName.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill in all fields before registering.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; // Stop execution
                          }

                          final authProvider = context.read<AuthProvider>();

                          // 3. Attempt to Register
                          bool registerSuccess = await authProvider.register(
                            firstName,
                            lastName,
                            email,
                            password,
                          );

                          if (!mounted) return;

                          if (registerSuccess) {
                            // 4. Registration successful! Immediately log them in
                            bool loginSuccess = await authProvider.login(
                              email,
                              password,
                            );

                            if (!mounted) return;

                            if (loginSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Welcome, $firstName!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // 5. Navigate directly to the Seeker Dashboard, clearing the navigation stack
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ScreenSeekerDashboard(),
                                ),
                                (route) =>
                                    false, // Prevents the user from clicking the "Back" button to return to the signup page
                              );
                            } else {
                              // Fallback in case automatic login fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Registration successful. Please login.",
                                  ),
                                ),
                              );
                              Navigator.pop(context); // Go back to login screen
                            }
                          } else {
                            // Show backend errors (like "Duplicate Email")
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authProvider.errorMessage ??
                                      "Registration failed.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text("Register"),
                      ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenLogin(),
                      ),
                    );
                  },
                  child: const Text("Already have an account? Sign here"),
                ),
              ],
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
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 85,
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
              _buildNavLink(
                "Home",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenHome()),
                ),
              ),
              _buildNavLink(
                "Jobs",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScreenHome()),
                ),
              ),
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

  Widget _buildNavLink(
    String text,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
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
      ),
    );
  }
}
