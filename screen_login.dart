import 'package:flutter/material.dart';
import 'package:neis_cap/screen_job.dart';
import 'package:provider/provider.dart'; // <--- ADDED THIS
import 'package:neis_cap/auth_provider.dart';

import 'Frontend-jobseeker/seeker_dashboard.dart';
import 'screen_singup.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

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
                        ),
                        onPressed: () async {
                          bool success = await context
                              .read<AuthProvider>()
                              .login(
                                _emailController.text,
                                _passwordController.text,
                              );

                          // FIXED ASYNC GAP WARNING
                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login Successful!"),
                              ),
                            );
                            // Navigate to Dashboard here
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ScreenSeekerDashboard(),
                              ),
                            );
                          }
                        },
                        child: const Text("Login"),
                      ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenSignup(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Register here"),
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
