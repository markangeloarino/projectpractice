import 'package:flutter/material.dart';
import 'package:neis_cap/Frontend-jobmatching/matching_dashboard.dart';
import 'package:neis_cap/Frontend-jobposting/post_vacancy.dart';
import 'package:neis_cap/admin_provider.dart';
import 'package:neis_cap/screen_staff_login.dart';
import 'package:neis_cap/Frontend-jobseeker/seeker_dashboard.dart';
import 'package:neis_cap/screen_login.dart';
import 'package:neis_cap/screen_singup.dart'; 
import 'package:neis_cap/Frontend-jobposting/post_vacancy_provider.dart';
import 'package:neis_cap/screen_job.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VacancyProvider()), // Add this line
        ChangeNotifierProvider(create: (_) => AdminProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(   
      title: 'NEIS',
      theme: ThemeData( 
        useMaterial3: true,
        // This forces the app to use your local pubspec.yaml asset
        fontFamily: 'Roboto', 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Set the Staff Dashboard as your temporary home screen to test it!
      home: const ScreenJobPosterDashboard(), 
    );
  }
}
// ScreenStaffLogin

// "Naga Job: Job Vacancies Management System",

// admin@naga.gov.ph
// admin123

// mark@gmail.com
// a01b63a4
// node server.js

// angelo@gmail.com
// 3a58e391